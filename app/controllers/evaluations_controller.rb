# -*- encoding : utf-8 -*-
class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: [:process_feedback]
  skip_before_action :require_login, only: [:export]

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

  def export
    if params[:provider].present?
      mooc_provider = MoocProvider.find_by(name: params[:provider])
      if mooc_provider.present?
        courses = Course.where(mooc_provider: mooc_provider)
      else #given provider not valid
        courses = Course.all
      end
    else #no provider given
      courses = Course.all
    end
    @courses_with_evaluations = []
    courses.each do |course|
      course_evaluations = Set.new
      course.evaluations.each do |evaluation|
        evaluation_object = {
            rating: evaluation.rating,
            description: evaluation.description,
            creation_date: evaluation.created_at,
            total_feedback_count: evaluation.total_feedback_count,
            helpful_feedback_count: evaluation.positive_feedback_count,
            course_status: evaluation.course_status.to_sym,
            is_verified: evaluation.is_verified
        }

        if evaluation.rated_anonymously
          evaluation_object[:user_name] = t('evaluations.anonymous')
        else
          evaluation_object[:user_name] = "#{evaluation.user.first_name} #{evaluation.user.last_name}"
        end
        course_evaluations << evaluation_object
      end

      course_with_evaluations = {
          course_id_from_provider: course.provider_course_id,
          mooc_provider: course.mooc_provider.name,
          overall_rating: course.calculated_rating,
          number_of_evaluations: course.rating_count,
          evaluations: course_evaluations
      }

      @courses_with_evaluations.push course_with_evaluations
    end

    respond_to do |format|
      format.json { render :export }
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
