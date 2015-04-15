require 'rails_helper'

RSpec.describe Recommendation, :type => :model do

  describe "sorted_recommendations_for(user, groups, course)" do
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }
    let(:second_group) { FactoryGirl.create(:group) }
    let(:course) { FactoryGirl.create(:course) }

    it "should return recommendations of user" do
      user_recommendation = FactoryGirl.create(:recommendation, users: [user])
      user_second_recommendation = FactoryGirl.create(:recommendation, users: [user])
      recommendations = Recommendation.sorted_recommendations_for(user, nil, nil)
      expect(recommendations).to match([[user_second_recommendation, nil], [user_recommendation, nil]])
    end

    it "should return recommendations of user" do
      groups_recommendation = FactoryGirl.create(:recommendation, groups: [second_group])
      groups_second_recommendation = FactoryGirl.create(:recommendation, groups: [group])
      recommendations = Recommendation.sorted_recommendations_for(nil, [group, second_group], nil)
      expect(recommendations).to match([[groups_second_recommendation, group], [groups_recommendation, second_group]])
    end

    it "should return recommendations of user and groups" do
      user_recommendation = FactoryGirl.create(:recommendation, users: [user])
      groups_recommendation = FactoryGirl.create(:recommendation, groups: [group])
      recommendations = Recommendation.sorted_recommendations_for(user, [group, second_group], nil)
      expect(recommendations).to match([[groups_recommendation, group], [user_recommendation, nil]])
    end

    it "should return recommendation of user and groups for specified course" do
      user_recommendation = FactoryGirl.create(:recommendation, users: [user], course: course)
      FactoryGirl.create(:recommendation, users: [user])
      groups_recommendation = FactoryGirl.create(:recommendation, groups: [group], course: course)
      recommendations = Recommendation.sorted_recommendations_for(user, [group, second_group], course)
      expect(recommendations).to match([[groups_recommendation, group], [user_recommendation, nil]])
    end

  end
end
