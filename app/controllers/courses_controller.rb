# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :set_course, only: %i[show enroll_course unenroll_course send_evaluation]
  skip_before_action :require_login, only: %i[index show filter_options search load_more]

  include ConnectorMapper

  # GET /courses
  # GET /courses.json
  def index
    load_courses

    @flash_notice_newsletter = :no_newsletter_advertising
    if current_user.blank?
      @flash_notice_newsletter = :no_user
    elsif current_user.unsubscribed_newsletter.nil?
      @flash_notice_newsletter = :current_user
    end

    unless performed?
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.info "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end

  def load_more
    load_courses

    respond_to do |format|
      format.html { render partial: '/courses/course_list_items' }
    end
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

    @course_languages = @course.language.blank? ? nil : @course.language.split(',')
    @subtitle_languages = @course.subtitle_languages.blank? ? nil : @course.subtitle_languages.split(',')

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

    @evaluations, @previous_course = Evaluation.collect_evaluation_objects_for_course(@course)
    evaluating_users = User.find(@course.evaluations.pluck(:user_id))
    @profile_pictures ||= {}
    @profile_pictures = User.user_profile_images_hash_for_users(evaluating_users, @profile_pictures)

    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses([@course])
    @bookmarked = false
    return if current_user.blank?
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
      rating = params[:rating].to_i
      description = params[:rating_textarea]
      course_status = params[:course_status].to_sym
      rated_anonymously = params[:rate_anonymously]
      Evaluation.save_or_update_evaluation(current_user.id, @course.id, rating, description, course_status, rated_anonymously)
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
    if params[:query].present?
      session['courses#index'] = {search_query: params[:query]}
    end
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
    return false if course_status.blank?
    %i[aborted enrolled finished].include? course_status.to_sym
  end

  def set_course
    @course = Course.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def course_params
    params.require(:course).permit(:name, :url, :course_instructor, :abstract, :language, :course_image, :videoId, :start_date, :end_date, :duration, :costs, :type_of_achievement, :categories, :difficulty, :requirements, :workload, :provider_course_id, :mooc_provider_id)
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
        @has_enrolled = (@has_enrolled ? true : false)
        @course.create_activity key: 'course.enroll', owner: current_user, group_ids: current_user.connected_groups_ids, user_ids: current_user.connected_users_ids if @has_enrolled
      rescue NotImplementedError
        @has_enrolled = nil
      end
    else
      # We didn't implement a provider_connector for this mooc_provider
      @has_enrolled = nil
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
        @has_unenrolled = (@has_unenrolled ? true : false)
      rescue NotImplementedError
        @has_unenrolled = nil
      end
    else
      # We didn't implement a provider_connector for this mooc_provider
      @has_unenrolled = nil
    end
  end

  def load_courses
    if params[:filterrific]
      filterrific_params = params[:filterrific].permit!.to_h
    else
      filterrific_params = nil
    end

    @filterrific = initialize_filterrific(Course, filterrific_params,
      select_options: {with_language: Course.options_for_languages,
                       with_mooc_provider_id: MoocProvider.options_for_select,
                       with_subtitle_languages: Course.options_for_subtitle_languages,
                       duration_filter_options: Course.options_for_duration,
                       start_filter_options: Course.options_for_start,
                       options_for_costs: Course.options_for_costs,
                       options_for_certificate: CourseTrackType.options_for_select,
                       options_for_sorted_by: Course.options_for_sorted_by}) || return

    @courses = @filterrific.find.page(params[:page])
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(@courses)

    @my_bookmarked_courses = if current_user.present?
                               current_user.bookmarks.collect(&:course)
                             else
                               []
                             end
  end
end
