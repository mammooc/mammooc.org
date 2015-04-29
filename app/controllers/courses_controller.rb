class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :enroll_course, :unenroll_course]
  skip_before_action :require_login, only: [:index, :show]
  include ConnectorMapper

  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all
    @provider_logos = AmazonS3.instance.get_provider_logos_hash_for_courses(@courses)
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
      @recommendations = Recommendation.sorted_recommendations_for_course_and_user(@course, current_user)
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

    @provider_logos = AmazonS3.instance.get_provider_logos_hash_for_courses([@course])
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
        @has_enrolled = provider_connector.enroll_user_for_course current_user, @course
        if @has_enrolled
          provider_worker = get_worker_by_mooc_provider @course.mooc_provider
          provider_worker.perform_async([current_user.id])
        end
      else
        # We didn't implement a provider_connector for this mooc_provider
        @has_enrolled = false
      end
    end

    def destroy_enrollment
      provider_connector = get_connector_by_mooc_provider @course.mooc_provider
      if provider_connector.present?
        @has_unenrolled = provider_connector.unenroll_user_for_course current_user, @course
        if @has_unenrolled
          provider_worker = get_worker_by_mooc_provider @course.mooc_provider
          provider_worker.perform_async([current_user.id])
        end
      else
        # We didn't implement a provider_connector for this mooc_provider
        @has_unenrolled = false
      end
    end
end
