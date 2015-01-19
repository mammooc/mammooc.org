class CourseAssignmentsController < ApplicationController
  before_action :set_course_assignment, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @course_assignments = CourseAssignment.all
    respond_with(@course_assignments)
  end

  def show
    respond_with(@course_assignment)
  end

  def new
    @course_assignment = CourseAssignment.new
    respond_with(@course_assignment)
  end

  def edit
  end

  def create
    @course_assignment = CourseAssignment.new(course_assignment_params)
    @course_assignment.save
    respond_with(@course_assignment)
  end

  def update
    @course_assignment.update(course_assignment_params)
    respond_with(@course_assignment)
  end

  def destroy
    @course_assignment.destroy
    respond_with(@course_assignment)
  end

  private
    def set_course_assignment
      @course_assignment = CourseAssignment.find(params[:id])
    end

    def course_assignment_params
      params.require(:course_assignment).permit(:name, :deadline, :maximum_score, :average_score, :course_id)
    end
end
