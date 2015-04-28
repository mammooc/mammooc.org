require 'rails_helper'

RSpec.describe "recommendations/_user_recommendation", :type => :view do
  before(:each) do
    @recommendation = FactoryGirl.create(:user_recommendation)
    @provider_logos = {}
    @profile_pictures = {}
  end

  it "renders the recommendation partial" do
    render 'recommendations/user_recommendation', recommendation: @recommendation, id: "recommendation_number_1"
    expect(rendered).to match(/#{@recommendation.course.name}/)
    expect(rendered).to match(/#{@recommendation.author.first_name} #{@recommendation.author.last_name}/)
    end
end
