# -*- encoding : utf-8 -*-
class CourseRequestsController < ApplicationController
  before_action :set_course_request, only: [:show, :edit, :update, :destroy]

  # GET /course_requests
  # GET /course_requests.json
  def index
    @course_requests = CourseRequest.all
  end

  # GET /course_requests/1
  # GET /course_requests/1.json
  def show
  end

  # GET /course_requests/new
  def new
    @course_request = CourseRequest.new
  end

  # GET /course_requests/1/edit
  def edit
  end

  # POST /course_requests
  # POST /course_requests.json
  def create
    @course_request = CourseRequest.new(course_request_params)

    respond_to do |format|
      if @course_request.save
        format.html { redirect_to @course_request, notice: 'Course request was successfully created.' }
        format.json { render :show, status: :created, location: @course_request }
      else
        format.html { render :new }
        format.json { render json: @course_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /course_requests/1
  # PATCH/PUT /course_requests/1.json
  def update
    respond_to do |format|
      if @course_request.update(course_request_params)
        format.html { redirect_to @course_request, notice: 'Course request was successfully updated.' }
        format.json { render :show, status: :ok, location: @course_request }
      else
        format.html { render :edit }
        format.json { render json: @course_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /course_requests/1
  # DELETE /course_requests/1.json
  def destroy
    @course_request.destroy
    respond_to do |format|
      format.html { redirect_to course_requests_url, notice: 'Course request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course_request
    @course_request = CourseRequest.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def course_request_params
    params.require(:course_request).permit(:date, :description, :course_id, :user_id, :group_id)
  end
end
