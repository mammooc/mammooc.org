# -*- encoding : utf-8 -*-
class RecommendationsController < ApplicationController
  load_and_authorize_resource only: [:create, :delete_user_from_recommendation, :delete_group_recommendation, :index, :new]

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      request.env['HTTP_REFERER'] ||= dashboard_path
      format.html { redirect_to :back, alert: t("unauthorized.#{exception.action}.recommendation") }
      format.json do
        error = {message: exception.message, action: exception.action, subject: exception.subject.id}
        render json: error.to_json, status: :unauthorized
      end
    end
  end

  # GET /recommendations
  # GET /recommendations.json
  def index
    @recommendations = current_user.recommendations.sort_by(&:created_at).reverse!
    recommendations_ids = @recommendations.collect(&:id)

    @provider_logos = AmazonS3.instance.provider_logos_hash_for_recommendations(@recommendations)
    @profile_pictures = User.author_profile_images_hash_for_recommendations(@recommendations)
    @rating_picture = AmazonS3.instance.get_url('five_stars.png')

    @activities = PublicActivity::Activity.order('created_at desc').where(trackable_id: recommendations_ids, trackable_type: 'Recommendation')
    @activity_courses = {}
    @activity_courses_bookmarked = {}
    return unless @activities
    @activities.each do |activity|
      @activity_courses[activity.id] = Recommendation.find(activity.trackable_id).course
      @activity_courses_bookmarked[activity.id] = @activity_courses[activity.id].bookmarked_by_user? current_user
    end
  end

  # GET /recommendations/new
  def new
    @recommendation = Recommendation.new
    session[:return_to] ||= request.referer
  end

  # POST /recommendations
  # POST /recommendations.json
  def create
    session[:return_to] ||= dashboard_dashboard_path
    user_ids = params[:recommendation][:related_user_ids].split(', ')
    group_ids = params[:recommendation][:related_group_ids].split(', ')

    user_ids.each do |user_id|
      recommendation = Recommendation.new(recommendation_params)
      recommendation.author = current_user
      recommendation.users.push(User.find(user_id))
      if recommendation.save!
        recommendation.create_activity key: 'recommendation.create', owner: current_user, recipient: recommendation.users.first, user_ids: [recommendation.users.first.id]
      end
    end

    group_ids.each do |group_id|
      recommendation = Recommendation.new(recommendation_params)
      recommendation.author = current_user
      recommendation.group = Group.find(group_id)
      recommendation.group.users.each do |user|
        recommendation.users.push(user)
      end
      if recommendation.save!
        recommendation.create_activity key: 'recommendation.create', owner: current_user, recipient: recommendation.group, group_ids: [recommendation.group.id], user_ids: recommendation.group.user_ids
      end
    end

    if params[:recommendation][:is_obligatory] == 'true'
      course = Course.find(params[:recommendation][:course_id])

      user_ids.each do |user_id|
        user = User.find(user_id)
        email_adress = user.primary_email
        UserMailer.obligatory_recommendation_user_notification(email_adress, user, course, current_user, root_url).deliver_later
      end

      group_ids.each do |group_id|
        group = Group.find(group_id)
        group.users.each do |user|
          if user != current_user
            email_adress = user.primary_email
            UserMailer.obligatory_recommendation_group_notification(email_adress, user, group, course, current_user, root_url).deliver_later
          end
        end
      end
    end

    respond_to do |format|
      if params[:recommendation][:is_obligatory] == 'true'
        format.html { redirect_to session.delete(:return_to), notice: t('recommendation.obligatory_recommendation.successfully_created') }
      else
        format.html { redirect_to session.delete(:return_to), notice: t('recommendation.successfully_created') }
      end
    end

  rescue ActiveRecord::RecordNotSaved
    flash[:error] = t('recommendation.creation_error')
    redirect_to root_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_recommendation
    @recommendation = Recommendation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def recommendation_params
    params.require(:recommendation).permit(:is_obligatory, :group_id, :course_id, :text)
  end
end
