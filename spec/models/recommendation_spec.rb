require 'rails_helper'

RSpec.describe Recommendation, :type => :model do

  describe "sorted_recommendations_for_course_and_user(course, user)" do
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, users: [user]) }
    let(:second_group) { FactoryGirl.create(:group) }
    let(:course) { FactoryGirl.create(:course) }


    it "should return recommendation of user for specified course" do
      user_recommendation = FactoryGirl.create(:recommendation, users: [user], course: course)
      FactoryGirl.create(:recommendation, users: [user])
      groups_recommendation = FactoryGirl.create(:recommendation, group: group, course: course)
      recommendations = Recommendation.sorted_recommendations_for_course_and_user(course, user)
      expect(recommendations).to match([groups_recommendation, user_recommendation])
    end

  end
end
