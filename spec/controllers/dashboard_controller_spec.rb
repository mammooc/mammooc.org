# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    sign_in user
  end

  describe 'GET dashboard' do
    it 'returns http success' do
      get :dashboard
      expect(response).to have_http_status(:success)
    end
    describe 'check activities' do
      let!(:user2) { FactoryGirl.create(:user) }
      let!(:group) { FactoryGirl.create(:group, users: [user, user2]) }

      it 'only shows activities from my groups members' do
        user3 = FactoryGirl.create(:user)
        FactoryGirl.create(:group, users: [user, user3])
        user4 = FactoryGirl.create(:user)
        user4_activity = FactoryGirl.create(:activity_bookmark, owner: user4, user_ids: [user.id])
        user3_activity = FactoryGirl.create(:activity_bookmark, owner: user3, user_ids: [user.id])
        user2_activity = FactoryGirl.create(:activity_bookmark, owner: user2, user_ids: [user.id])
        get :dashboard
        expect(assigns(:activities)).to include(user3_activity)
        expect(assigns(:activities)).to include(user2_activity)
        expect(assigns(:activities)).not_to include(user4_activity)
      end

      it 'filters out my own activities' do
        my_activity = FactoryGirl.create(:activity_bookmark, owner: user, user_ids: [user.id])
        get :dashboard
        expect(assigns(:activities)).not_to include(my_activity)
      end

      it 'filters out activities not directed at me or one of my groups' do
        activity_to_me = FactoryGirl.create(:activity_bookmark, owner: user2, user_ids: [user.id])
        activity_to_my_group = FactoryGirl.create(:activity_bookmark, owner: user2, group_ids: [group.id])
        activity_without_me = FactoryGirl.create(:activity_bookmark, owner: user2)
        get :dashboard
        expect(assigns(:activities)).to include(activity_to_me)
        expect(assigns(:activities)).not_to include(activity_to_my_group)
        expect(assigns(:activities)).not_to include(activity_without_me)
      end

      it 'does not filter any trackable_type of activity' do
        activity_bookmark = FactoryGirl.create(:activity_bookmark, owner: user2, user_ids: [user.id])
        activity_group_join = FactoryGirl.create(:activity_group_join, owner: user2, user_ids: [user.id])
        activity_course_enroll = FactoryGirl.create(:activity_course_enroll, owner: user2, user_ids: [user.id])
        activity_group_recommendation = FactoryGirl.create(:activity_group_recommendation, owner: user2, user_ids: [user.id])
        activity_user_recommendation = FactoryGirl.create(:activity_user_recommendation, owner: user2, user_ids: [user.id])

        get :dashboard

        expect(assigns(:activities)).to include(activity_bookmark)
        expect(assigns(:activities)).to include(activity_group_join)
        expect(assigns(:activities)).to include(activity_course_enroll)
        expect(assigns(:activities)).to include(activity_group_recommendation)
        expect(assigns(:activities)).to include(activity_user_recommendation)
      end
    end
  end
end
