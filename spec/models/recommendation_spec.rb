# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe Recommendation, type: :model do
  describe 'sorted_recommendations_for_course_and_user(course, user)' do
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, users: [user]) }
    let(:second_group) { FactoryGirl.create(:group) }
    let(:course) { FactoryGirl.create(:course) }

    it 'returns recommendation of user for specified course' do
      user_recommendation = FactoryGirl.create(:user_recommendation, users: [user], course: course)
      FactoryGirl.create(:user_recommendation, users: [user])
      groups_recommendation = FactoryGirl.create(:group_recommendation, group: group, course: course)
      recommendations = described_class.sorted_recommendations_for_course_and_user(course, user)
      expect(recommendations).to match([groups_recommendation, user_recommendation])
    end
  end

  describe 'delete_user_from_recommendation' do
    let(:user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, users: [user,second_user]) }
    let(:course) { FactoryGirl.create(:course) }


    it 'does not destroy the recommendations if there are users left' do
      user_recommendation = FactoryGirl.create(:user_recommendation, users: [user, second_user], course: course)
      expect do
        user_recommendation.delete_user_from_recommendation user
      end.to change(Recommendation, :count).by(0)
    end

    it 'does not destroy the recommendations if there is a group left' do
      user_recommendation = FactoryGirl.create(:user_recommendation, users: [user], group: group, course: course)
      expect do
        user_recommendation.delete_user_from_recommendation user
      end.to change(Recommendation, :count).by(0)
    end

    it 'destroys the recommendations if there are no users or group left' do
      user_recommendation = FactoryGirl.create(:user_recommendation, users: [user], course: course)
      expect do
        user_recommendation.delete_user_from_recommendation user
      end.to change(Recommendation, :count).by(-1)
    end
  end
end
