require 'rails_helper'

RSpec.describe "recommendations/show", :type => :view do
  before(:each) do
    @recommendation = assign(:recommendation, Recommendation.create!(
      :is_obligatory => false,
      :user => nil,
      :group => nil,
      :course => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/false/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
