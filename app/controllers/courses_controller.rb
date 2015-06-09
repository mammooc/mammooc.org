# -*- encoding : utf-8 -*-
class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :enroll_course, :unenroll_course]
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

    # RECOMMENDATIONS
    if user_signed_in?
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
    end

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

  def filter_options
    @filter_options = session['courses#index'].to_query('filterrific')

    respond_to do |format|
      format.json { render :filter_options }
    end
  end

  def search
    session['courses#index'] = {'search_query': params[:query], 'with_tracks': {'costs': '', 'certificate': ''}}
    redirect_to courses_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def course_params
    params.require(:course).permit(:name, :url, :course_instructor, :abstract, :language, :imageId, :videoId, :start_date, :end_date, :duration, :costs, :type_of_achievement, :categories, :difficulty, :requirements, :workload, :provider_course_id, :mooc_provider_id, :course_result_id)
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
