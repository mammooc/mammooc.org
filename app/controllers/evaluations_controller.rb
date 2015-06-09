# -*- encoding : utf-8 -*-
class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: [:show, :edit, :update, :destroy, :process_evaluation_rating]

  respond_to :html

  def index
    @evaluations = Evaluation.all
    respond_with(@evaluations)
  end

  def show
    respond_with(@evaluation)
  end

  def new
    @evaluation = Evaluation.new
    respond_with(@evaluation)
  end

  def edit
  end

  def create
    @evaluation = Evaluation.new(evaluation_params)
    @evaluation.save
    respond_with(@evaluation)
  end

  def update
    @evaluation.update(evaluation_params)
    respond_with(@evaluation)
  end

  def destroy
    @evaluation.destroy
    respond_with(@evaluation)
  end

  def process_evaluation_rating
    if params['helpful'] == 'true'
      @evaluation.evaluation_helpful_rating_count += 1
      @evaluation.evaluation_rating_count += 1
      @evaluation.save
    elsif params['helpful'] == 'false'
      @evaluation.evaluation_rating_count += 1
      @evaluation.save
    end
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :process_evaluation_rating_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_evaluation
    @evaluation = Evaluation.find(params[:id])
  end

  def evaluation_params
    params.require(:evaluation).permit(:title, :rating, :is_verified, :description, :date, :user_id, :course_id)
  end
end
