# -*- encoding : utf-8 -*-
class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :enroll_course, :unenroll_course, :send_evaluation]
  skip_before_action :require_login, only: [:index, :show]
  include ConnectorMapper

  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(@courses)
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

    # RECOMMENDATIONS
    if user_signed_in?
      recommendations = Recommendation.sorted_recommendations_for_course_and_user(@course, current_user, [current_user])
      params[:page] ||= 1
      @recommendations = recommendations.paginate(page: params[:page], per_page: 5)
      @profile_pictures = AmazonS3.instance.author_profile_images_hash_for_recommendations(@recommendations)
      @recommended_by = []
      @pledged_by = []
      @recommendations.each do |recommendation|
        if recommendation.is_obligatory
          @pledged_by.push(recommendation.author)
        else

          @recommended_by.push(recommendation.author)
        end
      end
      @evaluation = current_user.evaluations.find_by(course_id: @course.id)
    end

    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses([@course])
    @has_rated_course = Evaluation.find_by(user_id: current_user.id, course_id: @course.id).present?
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
    rating = params[:rating].to_i
    course_status = params[:course_status].to_i
    @errors ||= []
    unless ranking_valid? rating
      @errors << 'Die Gesamtbewertung muss angegeben werden'
    end
    unless course_status_valid? course_status
      @errors << 'Dein Kursstatus muss angegeben werden'
    end
    if @errors.empty?
      @evaluation = Evaluation.find_or_initialize_by(user_id: current_user.id, course_id: @course.id)
      @evaluation.rating = rating
      @evaluation.description = params[:rating_textarea]
      @evaluation.course_status = course_status
      @evaluation.rated_anonymously = params[:rate_anonymously]
      @evaluation.date = Time.zone.now
      @evaluation.user_id = current_user.id
      @evaluation.course_id = @course.id
      @evaluation.save
      @saved_evaluation_successfuly = true
    else
      @saved_evaluation_successfuly = false
    end
    @respond_partial = render_to_string partial: 'courses/already_rated', formats:[:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :send_evaluation_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def ranking_valid? rating
    return rating == 1 || rating == 2 || rating == 3 || rating == 4 || rating == 5
  end

  def course_status_valid? course_status
    return course_status == 1 || course_status == 2 || course_status == 3
  end

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
