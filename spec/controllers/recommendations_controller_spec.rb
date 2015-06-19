# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe RecommendationsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:second_user) { FactoryGirl.create(:user) }
  let(:third_user) { FactoryGirl.create(:user) }

  let!(:group) do
    group = FactoryGirl.create :group, users: [user]
    UserGroup.set_is_admin(group.id, user.id, true)
    group
  end
  let(:second_group) { FactoryGirl.create(:group) }

  let(:course) { FactoryGirl.create(:course) }

  let(:valid_model_attributes) { {author: second_user, is_obligatory: 'false', group: group, users: [user, third_user], course: course} }
  let(:valid_controller_attributes_group) { {author: user, is_obligatory: 'false', related_group_ids: "#{group.id}", related_user_ids: '', course_id: course.id} }
  let(:valid_controller_attributes_user) { {author: user, is_obligatory: 'false', related_user_ids: "#{second_user.id}", related_group_ids: '', course_id: course.id} }
  let(:valid_controller_attributes_multiple_users) { {author: user, is_obligatory: 'false', related_group_ids: '', related_user_ids: "#{second_user.id}, #{third_user.id}", course_id: course.id} }
  let(:valid_controller_attributes_multiple) { {author: user, is_obligatory: 'false', related_group_ids: "#{group.id}, #{second_group.id}", related_user_ids: "#{second_user.id}, #{third_user.id}", course_id: course.id} }
  let(:valid_controller_attributes_multiple_obligatory) { {author: user, is_obligatory: 'true', related_group_ids: "#{group.id}, #{second_group.id}", related_user_ids: "#{second_user.id}, #{third_user.id}", course_id: course.id} }

  before(:each) do
    sign_in user
    ActionMailer::Base.deliveries.clear
  end

  describe 'GET index' do
    it 'assigns all recommendations as @recommendations' do
      recommendation = Recommendation.create! valid_model_attributes
      get :index, {}
      expect(assigns(:recommendations)).to eq([recommendation])
    end

    describe 'check activities' do
      let!(:user2) { FactoryGirl.create(:user)}
      let!(:group) { FactoryGirl.create(:group, users: [user, user2])}

      it 'only shows activities from my groups members' do
        user3 = FactoryGirl.create(:user)
        FactoryGirl.create(:group, users: [user, user3])
        user4 = FactoryGirl.create(:user)
        user4_activity = FactoryGirl.create(:activity_user_recommendation, owner: user4, user_ids: [user.id])
        user3_activity = FactoryGirl.create(:activity_user_recommendation, owner: user3, user_ids: [user.id])
        user2_activity = FactoryGirl.create(:activity_user_recommendation, owner: user2, user_ids: [user.id])
        get :index
        expect(assigns(:activities)).to include(user3_activity)
        expect(assigns(:activities)).to include(user2_activity)
        expect(assigns(:activities)).not_to include(user4_activity)

      end


      it 'filters out my own activities' do
        my_activity = FactoryGirl.create(:activity_user_recommendation, owner: user, user_ids: [user.id])
        get :index
        expect(assigns(:activities)).not_to include(my_activity)
      end

      it 'filters out activities not directed at me or one of my groups' do
        activity_to_me = FactoryGirl.create(:activity_user_recommendation, owner: user2, user_ids: [user.id])
        activity_to_my_group = FactoryGirl.create(:activity_user_recommendation, owner: user2, group_ids: [group.id])
        activity_without_me = FactoryGirl.create(:activity_user_recommendation, owner: user2)
        get :index
        expect(assigns(:activities)).to include(activity_to_me)
        expect(assigns(:activities)).not_to include(activity_to_my_group)
        expect(assigns(:activities)).not_to include(activity_without_me)
      end

      it 'filters out anything that is not a user_recommendation' do
        activity_bookmark = FactoryGirl.create(:activity_bookmark, owner: user2, user_ids: [user.id])
        activity_group_join = FactoryGirl.create(:activity_group_join, owner: user2, user_ids: [user.id])
        activity_course_enroll = FactoryGirl.create(:activity_course_enroll, owner: user2, user_ids: [user.id])
        activity_user_recommendation = FactoryGirl.create(:activity_user_recommendation, owner: user2, user_ids: [user.id])

        get :index

        expect(assigns(:activities)).not_to include(activity_bookmark)
        expect(assigns(:activities)).not_to include(activity_group_join)
        expect(assigns(:activities)).not_to include(activity_course_enroll)
        expect(assigns(:activities)).to include(activity_user_recommendation)

      end
    end
  end

  describe 'GET new' do
    it 'assigns a new recommendation as @recommendation' do
      get :new, {}
      expect(assigns(:recommendation)).to be_a_new(Recommendation)
    end
  end

  describe 'POST create' do
    it 'creates a new Recommendation' do
      expect { post :create, recommendation: valid_controller_attributes_user }.to change(Recommendation, :count).by(1)
    end

    it 'creates a new Activity' do
      expect { post :create, recommendation: valid_controller_attributes_user }.to change(PublicActivity::Activity, :count).by(1)
    end

    it 'redirects to dashboard' do
      post :create, recommendation: valid_controller_attributes_user
      expect(response).to redirect_to dashboard_dashboard_path
    end

    it 'adds relations to specified groups' do
      post :create, recommendation: valid_controller_attributes_group
      expect(Recommendation.last.group).to eq group
      expect(Recommendation.last.users).to match_array(group.users)
    end

    it 'adds relations to specified users' do
      post :create, recommendation: valid_controller_attributes_multiple_users
      Recommendation.all.each do |recommendation|
        expect(recommendation.users & [third_user, second_user]).not_to be_blank
      end
    end

    it 'adds relations to specified course' do
      post :create, recommendation: valid_controller_attributes_group
      expect(Recommendation.last.course).to eql course
    end

    it 'creates one recommendation for each specified user or group' do
      expect { post :create, recommendation: valid_controller_attributes_multiple }.to change(Recommendation, :count).by(4)
    end

    it 'sends no email if recommendation is not obligatory' do
      post :create, recommendation: valid_controller_attributes_group
      expect(ActionMailer::Base.deliveries.count).to eq 0
    end

    describe 'obligatory recommendations' do
      let(:valid_controller_attributes_user_obligatory) { {author: user, is_obligatory: 'true', related_user_ids: "#{second_user.id}", related_group_ids: '', course_id: course.id} }
      let(:group_for_obligatory) { FactoryGirl.create(:group, users: [user, second_user]) }
      let(:valid_controller_attributes_group_obligatory) { {author: user, is_obligatory: 'true', related_group_ids: "#{group_for_obligatory.id}", related_user_ids: '', course_id: course.id} }

      it 'creates obligatory recommendations for each specified user or group' do
        expect { post :create, recommendation: valid_controller_attributes_multiple_obligatory }.to change(Recommendation, :count).by(4)
        expect(Recommendation.where(is_obligatory: true).count).to eq 4
      end

      it 'sends an email to specified user' do
        post :create, recommendation: valid_controller_attributes_user_obligatory
        expect(ActionMailer::Base.deliveries.count).to eq 1
      end

      it 'sends an email to every group member of specified group except the author of the obligatory recommendation' do
        post :create, recommendation: valid_controller_attributes_group_obligatory
        expect(ActionMailer::Base.deliveries.count).to eq group_for_obligatory.users.count - 1
      end
    end
  end
end
