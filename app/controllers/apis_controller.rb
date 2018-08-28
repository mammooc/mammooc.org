# frozen_string_literal: true

class ApisController < ApplicationController
  skip_before_action :require_login, only: %i[current_user_with_evaluation statistics]
  protect_from_forgery except: %i[current_user_with_evaluation statistics]

  def current_user_with_evaluation
    result = {}
    if current_user.present?
      @user = {
        name: current_user.first_name + ' ' + current_user.last_name,
        profile_picture: ApplicationController.helpers.asset_url(current_user.profile_image.url(:thumb))
      }
      @logged_in = true
      raise ActionController::ParameterMissing.new('no provider or course given') unless params[:provider].present? && params[:course_id].present?

      mooc_provider = MoocProvider.find_by!(name: params[:provider])
      course = [Course.find_by!(provider_course_id: params[:course_id], mooc_provider: mooc_provider)]

      if current_user.evaluations.where(course: course).present?
        @evaluation = current_user.evaluations.where(course: course).first.as_json.slice('rating', 'is_verified', 'description', 'course_status', 'rated_anonymously')
      end

    else
      @logged_in = false
    end

    result[:logged_in] = @logged_in
    result[:user] = @user
    result[:evaluation] = @evaluation

    respond_to do |format|
      format.js do
        render json: result, callback: CGI.escape(params[:callback])
      end
      format.json { render json: result }
    end
  rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.json { render json: {error: e.message}, status: :not_found }
      format.js { render json: {error: e.message}, callback: CGI.escape(params[:callback]), status: :not_found }
    end
  end

  def statistics
    result = {}
    result[:global_statistic] = {}
    statistics = result[:global_statistic]

    statistics[:mooc_provider] = MoocProvider.count
    statistics[:courses] = Course.count
    statistics[:course_tracks] = CourseTrack.count
    statistics[:organisations] = Organisation.count
    statistics[:users] = User.count
    statistics[:users_last_day] = User.where(created_at: (Time.zone.now - 1.day)..Time.zone.now).count
    statistics[:users_last_7days] = User.where(created_at: (Time.zone.now - 7.days)..Time.zone.now).count
    statistics[:groups] = Group.count
    statistics[:total_recommendations] = Recommendation.count
    statistics[:recommendations] = Recommendation.where(is_obligatory: false).count
    statistics[:mandatory_recommendations] = Recommendation.where(is_obligatory: true).count
    statistics[:bookmarks] = Bookmark.count
    statistics[:evaluations] = Evaluation.count

    respond_to do |format|
      format.js { render json: result }
      format.json { render json: result }
    end
  end
end
