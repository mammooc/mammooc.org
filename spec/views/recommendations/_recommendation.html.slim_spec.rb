require 'rails_helper'

RSpec.describe "recommendations/_recommendation", :type => :view do
  before(:each) do
    @recommendation = FactoryGirl.create(:recommendation)
  end

  it "renders the recommendation partial" do
    render 'recommendations/recommendation', recommendation: @recommendation, group: nil
    expect(rendered).to match(/#{@recommendation.course.name}/)
    expect(rendered).to match(/#{@recommendation.author.first_name} #{@recommendation.author.last_name}/)
    end
end
