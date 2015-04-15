class RecommendationsController < ApplicationController
  before_action :set_recommendation, only: [:update, :destroy, :delete]

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
    @recommendation = Recommendation.new(recommendation_params)
    @recommendation.author = @current_user
    user_ids = params[:recommendation][:related_user_ids].split(',')
    @recommendation.users += User.where id: user_ids
    group_ids = params[:recommendation][:related_group_ids].split(',')
    @recommendation.groups += Group.where id: group_ids
    session[:return_to] ||= dashboard_dashboard_path
    respond_to do |format|
      if @recommendation.save
        format.html { redirect_to session.delete(:return_to), notice: t('recommendation.successfully_created') }
      else
        format.html { redirect_to :back, notice: t('recommendation.creation_error')}
      end
    end
  end


  def delete
    if params[:group]
      @recommendation.groups -= [params[:group]]
    else
      @recommendation.users -= [current_user]
    end
    if @recommendation.users.empty? && @recommendation.groups.empty?
      @recommendation.destroy
    end
    respond_to do |format|
      format.html { redirect_to recommendations_url, notice: t('recommendation.successfully_destroyed') }
      format.json { head :no_content }
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
