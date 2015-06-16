class ActivitiesController < ApplicationController
  def delete_group_from_newsfeed_entry
    @activity = PublicActivity::Activity.find(params[:id])
    @activity.group_ids -= [params[:group_id]]
    @activity.save
    if @activity.user_ids.empty? && @activity.group_ids.empty?
      @activity.destroy
    end
    respond_to do |format|
      format.html { redirect_to :back, notice: t('newsfeed.successfully_destroyed') }
    end
  end

  def delete_user_from_newsfeed_entry
    @activity = PublicActivity::Activity.find(params[:id])
    @activity.user_ids -= [current_user.id]
    @activity.save
    if (!@activity.user_ids || @activity.user_ids.empty?) && (!@activity.group_ids || @activity.group_ids.empty?)
      @activity.destroy
    end
    respond_to do |format|
      format.html { redirect_to :back, notice: t('newsfeed.successfully_destroyed') }
    end
  end
end
