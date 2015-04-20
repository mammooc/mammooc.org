class CoursesController < ApplicationController
  before_action :set_course, only: [:show]
  skip_before_action :require_login, only: [:index, :show]

  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all
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
      @recommendations = Recommendation.sorted_recommendations_for(current_user, current_user.groups, @course)
      @recommended_by = []
      @pledged_by = []
      @recommendations.each do |recommendation_array|
        if recommendation_array[0].is_obligatory
          @pledged_by.push(recommendation_array[0].user)
        else
          @recommended_by.push(recommendation_array[0].user)
        end
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
end
