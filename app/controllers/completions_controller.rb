# -*- encoding : utf-8 -*-
class CompletionsController < ApplicationController
  before_action :set_completion, only: [:show, :edit, :update, :destroy]

  # GET /completions
  # GET /completions.json
  def index
    @completions = Completion.all
  end

  # GET /completions/1
  # GET /completions/1.json
  def show
  end

  # GET /completions/new
  def new
    @completion = Completion.new
  end

  # GET /completions/1/edit
  def edit
  end

  # POST /completions
  # POST /completions.json
  def create
    @completion = Completion.new(completion_params)

    respond_to do |format|
      if @completion.save
        format.html { redirect_to @completion, notice: 'Completion was successfully created.' }
        format.json { render :show, status: :created, location: @completion }
      else
        format.html { render :new }
        format.json { render json: @completion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /completions/1
  # PATCH/PUT /completions/1.json
  def update
    respond_to do |format|
      if @completion.update(completion_params)
        format.html { redirect_to @completion, notice: 'Completion was successfully updated.' }
        format.json { render :show, status: :ok, location: @completion }
      else
        format.html { render :edit }
        format.json { render json: @completion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /completions/1
  # DELETE /completions/1.json
  def destroy
    @completion.destroy
    respond_to do |format|
      format.html { redirect_to completions_url, notice: 'Completion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_completion
    @completion = Completion.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def completion_params
    params.require(:completion).permit(:position_in_course, :points, :permissions, :date, :user_id, :course_id)
  end
end
