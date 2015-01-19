class UserAssignmentsController < ApplicationController
  before_action :set_user_assignment, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @user_assignments = UserAssignment.all
    respond_with(@user_assignments)
  end

  def show
    respond_with(@user_assignment)
  end

  def new
    @user_assignment = UserAssignment.new
    respond_with(@user_assignment)
  end

  def edit
  end

  def create
    @user_assignment = UserAssignment.new(user_assignment_params)
    @user_assignment.save
    respond_with(@user_assignment)
  end

  def update
    @user_assignment.update(user_assignment_params)
    respond_with(@user_assignment)
  end

  def destroy
    @user_assignment.destroy
    respond_with(@user_assignment)
  end

  private
    def set_user_assignment
      @user_assignment = UserAssignment.find(params[:id])
    end

    def user_assignment_params
      params.require(:user_assignment).permit(:date, :score, :user_id, :course_id, :course_assignment_id)
    end
end
