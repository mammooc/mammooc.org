# frozen_string_literal: true
class ApisController < ApplicationController
  skip_before_action :require_login, only: [:current_user_with_evaluation]
  protect_from_forgery except: :current_user_with_evaluation

  def current_user_with_evaluation
    result = {}
    if current_user.present?
      @user = {
        name: current_user.first_name + ' ' + current_user.last_name,
        profile_picture: ApplicationController.helpers.asset_url(current_user.profile_image.url(:thumb))
      }
      @logged_in = true
      if params[:provider].present? && params[:course_id].present?
        mooc_provider = MoocProvider.find_by!(name: params[:provider])
        course = [Course.find_by!(provider_course_id: params[:course_id], mooc_provider: mooc_provider)]
      else
        raise ActionController::ParameterMissing.new('no provider or course given')
      end

      @evaluation = current_user.evaluations.where(course: course).first.attributes.slice('rating', 'is_verified', 'description', 'course_status', 'rated_anonymously')
    else
      @logged_in = false
    end

    result[:logged_in] = @logged_in
    result[:user] = @user
    result[:evaluation] = @evaluation

    respond_to do |format|
      format.js do
        render json: result, callback: params[:callback]
      end
      format.json { render json: result }
    end

  rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.json { render json: {error: e.message}, status: :recordNotFound }
    end
  end
end
