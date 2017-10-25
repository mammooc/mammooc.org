# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe 'GET dashboard' do
    it 'returns http success' do
      get :dashboard
      expect(response).to have_http_status(:success)
    end
    describe 'check activities' do
      let!(:user2) { FactoryBot.create(:user) }
      let!(:group) { FactoryBot.create(:group, users: [user, user2]) }

      it 'only shows activities from my groups members' do
        user3 = FactoryBot.create(:user)
        FactoryBot.create(:group, users: [user, user3])
        user4 = FactoryBot.create(:user)
        user4_activity = FactoryBot.create(:activity_bookmark, owner: user4, user_ids: [user.id])
        user3_activity = FactoryBot.create(:activity_bookmark, owner: user3, user_ids: [user.id])
        user2_activity = FactoryBot.create(:activity_bookmark, owner: user2, user_ids: [user.id])
        get :dashboard
        expect(assigns(:activities)).to include(user3_activity)
        expect(assigns(:activities)).to include(user2_activity)
        expect(assigns(:activities)).not_to include(user4_activity)
      end

      it 'filters out my own activities' do
        my_activity = FactoryBot.create(:activity_bookmark, owner: user, user_ids: [user.id])
        get :dashboard
        expect(assigns(:activities)).not_to include(my_activity)
      end

      it 'filters out activities not directed at me or one of my groups' do
        activity_to_me = FactoryBot.create(:activity_bookmark, owner: user2, user_ids: [user.id])
        activity_to_my_group = FactoryBot.create(:activity_bookmark, owner: user2, group_ids: [group.id])
        activity_without_me = FactoryBot.create(:activity_bookmark, owner: user2)
        get :dashboard
        expect(assigns(:activities)).to include(activity_to_me)
        expect(assigns(:activities)).not_to include(activity_to_my_group)
        expect(assigns(:activities)).not_to include(activity_without_me)
      end

      it 'does not filter any trackable_type of activity' do
        activity_bookmark = FactoryBot.create(:activity_bookmark, owner: user2, user_ids: [user.id])
        activity_group_join = FactoryBot.create(:activity_group_join, owner: user2, user_ids: [user.id])
        activity_course_enroll = FactoryBot.create(:activity_course_enroll, owner: user2, user_ids: [user.id])
        activity_group_recommendation = FactoryBot.create(:activity_group_recommendation, owner: user2, user_ids: [user.id])
        activity_user_recommendation = FactoryBot.create(:activity_user_recommendation, owner: user2, user_ids: [user.id])
        user_setting = FactoryBot.create(:user_setting, name: :course_enrollments_visibility, user: user2)
        FactoryBot.create(:user_setting_entry, setting: user_setting, key: 'groups', value: [group.id])

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
