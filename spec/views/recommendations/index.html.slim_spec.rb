require 'rails_helper'

RSpec.describe "recommendations/index", :type => :view do
  let(:user) { FactoryGirl.create(:user) }
  let(:course) { FactoryGirl.create(:course) }
  let(:first_recommendation) {FactoryGirl.create(:recommendation, user: user, course: course)}
  let(:second_recommendation) {FactoryGirl.create(:recommendation, user: user, course: course)}

  before(:each) do
    @recommendations = [[first_recommendation, nil], [second_recommendation, nil]]
  end

  it "renders a list of recommendations" do
    render
    expect(rendered).to match(/#{first_recommendation.course.name}/)
    expect(rendered).to match(/#{second_recommendation.course.name}/)
    expect(rendered).to match(/#{first_recommendation.user.first_name} #{first_recommendation.user.last_name}/)
    expect(rendered).to match(/#{second_recommendation.user.first_name} #{second_recommendation.user.last_name}/)
  end
end
