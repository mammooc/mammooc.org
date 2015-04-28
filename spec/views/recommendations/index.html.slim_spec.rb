require 'rails_helper'

RSpec.describe "recommendations/index", :type => :view do
  let(:user) { FactoryGirl.create(:user) }
  let(:course) { FactoryGirl.create(:course) }
  let(:first_recommendation) {FactoryGirl.create(:user_recommendation, author: user, course: course)}
  let(:second_recommendation) {FactoryGirl.create(:user_recommendation, author: user, course: course)}

  before(:each) do
    @recommendations = [first_recommendation, second_recommendation]
    @provider_logos = {}
  end

  it "renders a list of recommendations" do
    render
    expect(rendered).to match(/#{first_recommendation.course.name}/)
    expect(rendered).to match(/#{second_recommendation.course.name}/)
    expect(rendered).to match(/#{first_recommendation.author.first_name} #{first_recommendation.author.last_name}/)
    expect(rendered).to match(/#{second_recommendation.author.first_name} #{second_recommendation.author.last_name}/)
  end
end
