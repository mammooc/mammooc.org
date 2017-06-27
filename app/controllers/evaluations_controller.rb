# frozen_string_literal: true

class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: [:process_feedback]
  skip_before_action :require_login, only: %i[export_course_evaluations export_overall_course_rating save login_and_save]
  protect_from_forgery except: %i[save login_and_save]

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

  def export_overall_course_rating
    raise ActionController::ParameterMissing.new('no provider given for the course') unless params[:provider].present? && params[:course_id].present?
    mooc_provider = MoocProvider.find_by!(name: params[:provider])
    course = Course.find_by!(provider_course_id: params[:course_id], mooc_provider: mooc_provider)

    @overall_course_rating = {
      course_id_from_provider: course.provider_course_id,
      mooc_provider: course.mooc_provider.name,
      overall_rating: course.calculated_rating,
      number_of_evaluations: course.rating_count
    }
    respond_to do |format|
      format.json { render :export_overall_course_rating }
    end
  rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.json { render json: {error: e.message}, status: :recordNotFound }
    end
  end

  def export_course_evaluations
    raise ActionController::ParameterMissing.new('no provider given for the course') unless params[:provider].present? && params[:course_id].present?
    mooc_provider = MoocProvider.find_by!(name: params[:provider])
    course = Course.find_by!(provider_course_id: params[:course_id], mooc_provider: mooc_provider)

    @courses_with_evaluations = []
    course_evaluations = Set.new
    course.evaluations.paginate(page: params[:page], per_page: params[:per_page]).each do |evaluation|
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
        evaluation_object[:user_name] = 'Anonymous'
        evaluation_object[:user_profile_picture] = root_url + Settings.default_profile_picture_path

      else
        evaluation_object[:user_name] = "#{evaluation.user.first_name} #{evaluation.user.last_name}"
        evaluation_object[:user_profile_picture] = ApplicationController.helpers.asset_url(evaluation.user.profile_image.url(:thumb))
      end
      course_evaluations << evaluation_object
    end

    course_with_evaluations = {
      course_id_from_provider: course.provider_course_id,
      mooc_provider: course.mooc_provider.name,
      overall_rating: course.calculated_rating,
      number_of_evaluations: course.rating_count,
      user_evaluations: course_evaluations
    }

    @courses_with_evaluations.push course_with_evaluations

    respond_to do |format|
      format.json { render :export_course_evaluations }
    end
  rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.json { render json: {error: e.message}, status: :recordNotFound }
    end
  end

  def save
    raise 'No User is logged in.' if current_user.blank?

    check_and_validate
    provider_course_id = params['course_id']
    mooc_provider = MoocProvider.find_by!(name: params[:provider])
    course = Course.find_by!(provider_course_id: provider_course_id, mooc_provider: mooc_provider)
    persist_evaluation course

    respond_to do |format|
      format.js do
        render json: {success: 'true'}, callback: params[:callback]
      end
      format.json { render json: {success: 'true'}, status: :ok }
    end
  rescue => e
    respond_to do |format|
      format.js do
        render json: {success: 'false', error: e.message}, callback: params[:callback]
      end
      format.json { render json: {success: 'false', error: e.message}, status: :ok }
    end
  end

  def login_and_save
    check_and_validate
    mooc_provider = MoocProvider.find_by!(name: params[:provider])

    if current_user.blank?
      if mooc_provider.oauth_path_for_login.blank?
        redirect_to new_user_registration_path # TODO: Pass params to registration so that the user is able to save the evaluation immediately.
      else
        redirect_to mooc_provider.oauth_path_for_login + '?' + params.to_unsafe_hash.to_param
      end
    else
      provider_course_id = params['course_id']

      course = Course.find_by!(provider_course_id: provider_course_id, mooc_provider: mooc_provider)
      persist_evaluation course

      flash['success'] ||= []
      flash['success'] << t('evaluations.thanks_for_feedback')
      redirect_to course_path(course)
    end
  rescue
    flash['error'] ||= []
    flash['error'] << t('global.ajax_failed')
    respond_to do |format|
      format.html { redirect_to dashboard_path }
    end
  end

  private

  def check_and_validate
    if params['rating'].nil? || params['rated_anonymously'].nil? || params['course_id'].nil? || params['provider'].nil? || params['course_status'].nil?
      raise ActionController::ParameterMissing.new('one of the following parameters is missing: rating, rated_anonymously, course_id, provider, course_status')
    end

    if params['rating'].blank? || params['rated_anonymously'].blank? || params['course_id'].blank? || params['provider'].blank? || params['course_status'].blank?
      raise ArgumentError.new('one of the following parameter was empty: rating, rated_anonymously, course_id, provider, course_status')
    end

    rating = params['rating'].to_i
    if rating.to_s != params['rating'] || rating < 1 || rating > 5
      raise ArgumentError.new('rating has no valid value')
    end

    begin
      StringHelper.to_bool(params['rated_anonymously'])
    rescue ArgumentError
      raise ArgumentError.new('rated_anonymously has no valid value')
    end

    course_status = params['course_status']
    raise ArgumentError.new('course_status has no valid value') if course_status != 'aborted' && course_status != 'finished' && course_status != 'enrolled'
  end

  def persist_evaluation(course)
    user_id = current_user.id
    rating = params['rating'].to_i
    description = params['description']
    course_status = params['course_status'].to_sym
    rated_anonymously = StringHelper.to_bool(params['rated_anonymously'])

    Evaluation.save_or_update_evaluation(user_id, course.id, rating, description, course_status, rated_anonymously)
  end

  def set_evaluation
    @evaluation = Evaluation.find(params[:id])
  end

  def evaluation_params
    params.require(:evaluation).permit(:title, :rating, :is_verified, :description, :date, :user_id, :course_id)
  end
end
