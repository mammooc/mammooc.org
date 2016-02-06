# encoding: utf-8
# frozen_string_literal: true

class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: [:process_feedback]

  respond_to :html

  def process_feedback
    unless @evaluation.user == current_user
      if params['helpful'] == 'true'
        @evaluation.positive_feedback_count += 1
        @evaluation.total_feedback_count += 1
        @evaluation.save
      elsif params['helpful'] == 'false'
        @evaluation.total_feedback_count += 1
        @evaluation.save
      end
    end
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :process_feedback_result, status: :ok }
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
