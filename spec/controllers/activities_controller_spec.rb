# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ActivitiesController, type: :controller do
  describe 'delete group newsfeed_entry' do
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let!(:group) { FactoryGirl.create(:group) }
    let!(:group2) { FactoryGirl.create(:group) }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    it 'destroys the requested newsfeed_entry of specified group' do
      request.env['HTTP_REFERER'] = dashboard_path
      activity = FactoryGirl.create(:activity_group_recommendation, group_ids: [group.id], user_ids: nil)
      expect do
        get :delete_group_from_newsfeed_entry, params: {id: activity.id, group_id: group.id}
      end.to change(PublicActivity::Activity, :count).by(-1)
    end

    it 'removes the specified group from activity' do
      request.env['HTTP_REFERER'] = dashboard_path
      activity = FactoryGirl.create(:activity_group_recommendation, group_ids: [group.id, group2.id], user_ids: nil)
      get :delete_group_from_newsfeed_entry, params: {id: activity.id, group_id: group.id}
      expect(PublicActivity::Activity.find(activity.id).group_ids.length).to eq 1
    end

    it 'removes the specified user from activity' do
      request.env['HTTP_REFERER'] = dashboard_path
      activity = FactoryGirl.create(:activity_user_recommendation, group_ids: nil, user_ids: [user.id, user2.id])
      get :delete_user_from_newsfeed_entry, params: {id: activity.id}
      expect(PublicActivity::Activity.find(activity.id).user_ids.length).to eq 1
    end

    it 'destroys the requested newsfeed_entry of specified user' do
      request.env['HTTP_REFERER'] = dashboard_path
      activity = FactoryGirl.create(:activity_user_recommendation, group_ids: nil, user_ids: [user.id])
      expect do
        get :delete_user_from_newsfeed_entry, params: {id: activity.id}
      end.to change(PublicActivity::Activity, :count).by(-1)
    end

    it 'destroys the requested recommendation of specified user' do
      request.env['HTTP_REFERER'] = dashboard_path
      activity = FactoryGirl.create(:activity_user_recommendation, group_ids: nil, user_ids: [user.id])
      expect do
        get :delete_user_from_newsfeed_entry, params: {id: activity.id}
      end.to change(Recommendation, :count).by(-1)
    end

    it 'destroys the requested recommendation of specified group' do
      request.env['HTTP_REFERER'] = dashboard_path
      activity = FactoryGirl.create(:activity_group_recommendation, group_ids: [group.id], user_ids: nil)
      expect do
        get :delete_group_from_newsfeed_entry, params: {id: activity.id, group_id: group.id}
      end.to change(Recommendation, :count).by(-1)
    end
  end
end
