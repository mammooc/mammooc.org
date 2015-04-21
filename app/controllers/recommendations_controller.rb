class RecommendationsController < ApplicationController
  before_action :set_recommendation, only: [:delete]
  load_and_authorize_resource only: [:create, :delete, :index, :new]

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      request.env["HTTP_REFERER"] ||= dashboard_path
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
    @recommendations = Recommendation.sorted_recommendations_for(current_user, current_user.groups, nil)
  end

  # GET /recommendations/new
  def new
    @recommendation = Recommendation.new
    session[:return_to] ||= request.referer
  end

  # POST /recommendations
  # POST /recommendations.json
  def create
    puts '############################################### start create'
    session[:return_to] ||= dashboard_dashboard_path
    user_ids = params[:recommendation][:related_user_ids].split(', ')
    group_ids = params[:recommendation][:related_group_ids].split(', ')


    user_ids.each do | user_id |
      recommendation = Recommendation.new(recommendation_params)
      recommendation.author = current_user
      recommendation.users.push(User.find(user_id))
      recommendation.save!
    end

    group_ids.each do | group_id |
      recommendation = Recommendation.new(recommendation_params)
      recommendation.author = current_user
      recommendation.group = Group.find(group_id)
      recommendation.group.users.each do | user |
        recommendation.users.push(user)
      end
      recommendation.save!
    end

    respond_to do |format|
        format.html { redirect_to session.delete(:return_to), notice: t('recommendation.successfully_created') }
      end

  rescue ActiveRecord::RecordNotSaved => error
    flash[:error] = t('recommendation.creation_error')
    redirect_to root_path

  end


  def delete
    if params[:group]
      @recommendation.groups -= [Group.find(params[:group])]
    else
      @recommendation.users -= [current_user]
    end
    if @recommendation.users.empty? && @recommendation.groups.empty?
      @recommendation.destroy
    end
    respond_to do |format|
      format.html { redirect_to recommendations_url, notice: t('recommendation.successfully_destroyed') }
    end
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
