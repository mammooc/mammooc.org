# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def delete_group_from_newsfeed_entry
    @activity = PublicActivity::Activity.find(params[:id])
    @activity.group_ids -= [params[:group_id]]
    @activity.save
    if @activity.trackable_type == 'Recommendation'
      Recommendation.find(@activity.trackable_id).delete_group_recommendation
    end
    @activity.destroy if @activity.user_ids.blank? && @activity.group_ids.blank?
    respond_to do |format|
      format.html { redirect_back(fallback_location: group_path(params[:group_id]), notice: t('newsfeed.successfully_destroyed')) }
    end
  end

  def delete_user_from_newsfeed_entry
    current_user.delete_user_from_activity PublicActivity::Activity.find(params[:id])
    respond_to do |format|
      format.html { redirect_back(fallback_location: dashboard_path, notice: t('newsfeed.successfully_destroyed')) }
    end
  end
end
