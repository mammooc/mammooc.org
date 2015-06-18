# -*- encoding : utf-8 -*-
class ActivitiesController < ApplicationController
  def delete_group_from_newsfeed_entry
    @activity = PublicActivity::Activity.find(params[:id])
    @activity.group_ids -= [params[:group_id]]
    @activity.save
    if @activity.trackable_type == 'Recommendation'
      Recommendation.find(@activity.trackable_id).delete_group_recommendation
    end
    if (@activity.user_ids.blank?) && (@activity.group_ids.blank?)
      @activity.destroy
    end
    respond_to do |format|
      format.html { redirect_to :back, notice: t('newsfeed.successfully_destroyed') }
    end
  end

  def test
    puts 'juhu'
  end

  def delete_user_from_newsfeed_entry
    @activity = PublicActivity::Activity.find(params[:id])
    @activity.user_ids -= [current_user.id]
    @activity.save
    if @activity.trackable_type == 'Recommendation'
      Recommendation.find(@activity.trackable_id).delete_user_from_recommendation current_user
    end
    if (@activity.user_ids.blank?) && (!@activity.group_ids.blank?)
      @activity.destroy
    end
    respond_to do |format|
      format.html { redirect_to :back, notice: t('newsfeed.successfully_destroyed') }
    end
  end
end
