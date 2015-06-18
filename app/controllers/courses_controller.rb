# -*- encoding : utf-8 -*-
class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :enroll_course, :unenroll_course, :send_evaluation]
  skip_before_action :require_login, only: [:index, :show, :filter_options, :search]

  include ConnectorMapper

  # GET /courses
  # GET /courses.json
  def index
    @filterrific = initialize_filterrific(Course, params[:filterrific],
      select_options: {with_language: Course.options_for_languages,
                       with_mooc_provider_id: MoocProvider.options_for_select,
                       with_subtitle_languages: Course.options_for_subtitle_languages,
                       duration_filter_options: Course.options_for_duration,
                       start_filter_options: Course.options_for_start,
                       options_for_costs: Course.options_for_costs,
                       options_for_certificate: CourseTrackType.options_for_select,
                       options_for_sorted_by: Course.options_for_sorted_by
      }) || return

    @courses = @filterrific.find.page(params[:page])
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(@courses)

    if current_user.present?
      @my_bookmarked_courses = current_user.bookmarks.collect(&:course)
    else
      @my_bookmarked_courses = []
    end

    respond_to do |format|
      format.html
      format.js
      format.json
    end

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.info "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    if @course.previous_iteration_id
      @previous_course_name = Course.find(@course.previous_iteration_id).name
    end
    if @course.following_iteration_id
      @following_course_name = Course.find(@course.following_iteration_id).name
    end

    @course_languages = (@course.language.blank?) ? nil : @course.language.split(',')
    @subtitle_languages = (@course.subtitle_languages.blank?) ? nil : @course.subtitle_languages.split(',')

    @recommendation = Recommendation.new(course: @course)

    if user_signed_in?
      # RECOMMENDATIONS
      recommendations = Recommendation.sorted_recommendations_for_course_and_user(@course, current_user, [current_user])
      @recommendations_total = recommendations.size
      params[:page] ||= 1
      @recommendations = recommendations.paginate(page: params[:page], per_page: 3)
      @profile_pictures = User.author_profile_images_hash_for_recommendations(@recommendations)
      @recommended_by = []
      @pledged_by = []
      @recommendations.each do |recommendation|
        if recommendation.is_obligatory
          @pledged_by.push(recommendation.author)
        else

          @recommended_by.push(recommendation.author)
        end
      end
      @has_groups = current_user.groups.any?
      @has_admin_groups = UserGroup.where(user: current_user, is_admin: true).collect(&:group_id).any?

      # EVALUATIONS
      @current_user_evaluation = current_user.evaluations.find_by(course_id: @course.id)
      @has_rated_course = Evaluation.find_by(user_id: current_user.id, course_id: @course.id).present?
    end

    create_evaluation_object_for_course @course
    evaluating_users = User.find(@course.evaluations.pluck(:user_id))
    @profile_pictures ||= {}
    @profile_pictures = User.user_profile_images_hash_for_users(evaluating_users, @profile_pictures)

    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses([@course])
    @bookmarked = false
    return unless current_user.present?
    current_user.bookmarks.each do |bookmark|
      @bookmarked = true if bookmark.course == @course
    end
  end

  def enroll_course
    respond_to do |format|
      begin
        create_enrollment
        format.html { redirect_to @course }
        format.json { render :enroll_course_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to @course }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def unenroll_course
    respond_to do |format|
      begin
        destroy_enrollment
        format.html { redirect_to @course }
        format.json { render :unenroll_course_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to @course }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def send_evaluation
    @errors ||= []
    unless ranking_valid? params[:rating].to_i
      @errors << t('evaluations.state_overall_rating')
    end
    unless course_status_valid? params[:course_status]
      @errors << t('evaluations.state_course_status')
    end

    if @errors.empty?
      evaluation = Evaluation.find_by(user_id: current_user.id, course_id: @course.id)
      if evaluation.blank?
        evaluation = Evaluation.new(user_id: current_user.id, course_id: @course.id)
        evaluation.creation_date = Time.zone.now
      end
      evaluation.rating = params[:rating].to_i
      evaluation.description = params[:rating_textarea]
      evaluation.course_status = params[:course_status].to_sym
      evaluation.rated_anonymously = params[:rate_anonymously]
      evaluation.update_date = Time.zone.now
      evaluation.save
    end
    @current_user_evaluation = current_user.evaluations.find_by(course_id: @course.id)
    @has_rated_course = @current_user_evaluation.present?
    @respond_partial = render_to_string partial: 'courses/already_rated_course_form', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to @course }
        format.json { render :send_evaluation_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to @course }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def filter_options
    @filter_options = session['courses#index'].to_query('filterrific')

    respond_to do |format|
      format.json { render :filter_options }
    end
  end

  def search
    session['courses#index'] = {search_query: params[:query]}
    redirect_to courses_path
  end

  def autocomplete
    @courses = Course.search_query params[:q]

    respond_to do |format|
      format.json
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def ranking_valid?(rating)
    [1, 2, 3, 4, 5].include? rating
  end

  def course_status_valid?(course_status)
    return false unless course_status.present?
    [:aborted, :enrolled, :finished].include? course_status.to_sym
  end

  def set_course
    @course = Course.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def course_params
    params.require(:course).permit(:name, :url, :course_instructor, :abstract, :language, :imageId, :videoId, :start_date, :end_date, :duration, :costs, :type_of_achievement, :categories, :difficulty, :requirements, :workload, :provider_course_id, :mooc_provider_id, :course_result_id)
  end

  def create_evaluation_object_for_course(course)
    if course.evaluations.present?
      @course_evaluations = Set.new
      course.evaluations.each do |evaluation|
        evaluation_object = {
          evaluation_id: evaluation.id,
          rating: evaluation.rating,
          description: evaluation.description,
          creation_date: evaluation.creation_date,
          evaluation_rating_count: evaluation.evaluation_rating_count,
          evaluation_helpful_rating_count: evaluation.evaluation_helpful_rating_count
        }
        case evaluation.course_status.to_sym
          when :aborted
            evaluation_object[:course_status] = t('evaluations.aborted_course')
          when :enrolled
            evaluation_object[:course_status] = t('evaluations.currently_enrolled_course')
          when :finished
            evaluation_object[:course_status] = t('evaluations.finished_course')
        end
        if evaluation.rated_anonymously
          evaluation_object[:user_id] = nil
          evaluation_object[:user_name] = t('evaluations.anonymous')
        else
          evaluation_object[:user_id] = evaluation.user_id
          evaluation_object[:user_name] = "#{evaluation.user.first_name} #{evaluation.user.last_name}"
        end
        @course_evaluations << evaluation_object
      end
    else
      @course_evaluations = nil
    end
  end

  def create_enrollment
    provider_connector = get_connector_by_mooc_provider @course.mooc_provider
    if provider_connector.present?
      begin
        @has_enrolled = provider_connector.enroll_user_for_course current_user, @course
        if @has_enrolled
          provider_worker = get_worker_by_mooc_provider @course.mooc_provider
          provider_worker.perform_async([current_user.id])
        end
      rescue NotImplementedError
        @has_enrolled = false
      end
    else
      # We didn't implement a provider_connector for this mooc_provider
      @has_enrolled = false
    end
  end

  def destroy_enrollment
    provider_connector = get_connector_by_mooc_provider @course.mooc_provider
    if provider_connector.present?
      begin
        @has_unenrolled = provider_connector.unenroll_user_for_course current_user, @course
        if @has_unenrolled
          provider_worker = get_worker_by_mooc_provider @course.mooc_provider
          provider_worker.perform_async([current_user.id])
        end
      rescue NotImplementedError
        @has_unenrolled = false
      end
    else
      # We didn't implement a provider_connector for this mooc_provider
      @has_unenrolled = false
    end
  end
end
