class ActivitiesController < ApplicationController
  def delete_group_from_newsfeed_entry group
    @activity.groups -= [group]
    if @activity.users.empty? && activity.groups.empty?
      @activity.destroy
    end
    respond_to do |format|
      format.html { redirect_to :back, notice: t('newsfeed.successfully_destroyed') }
    end
  end

  def delete_user_from_newsfeed_entry
    @activity.users -= [current_user]
    if @activity.users.empty? && @activity.groups.empty?
      @activity.destroy
    end
    respond_to do |format|
      format.html { redirect_to :back, notice: t('newsfeed.successfully_destroyed') }
    end
  end
end
