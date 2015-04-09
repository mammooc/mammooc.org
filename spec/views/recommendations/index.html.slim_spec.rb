require 'rails_helper'

RSpec.describe "recommendations/index", :type => :view do
  let(:user) { FactoryGirl.create(:user) }
  let(:course) { FactoryGirl.create(:course) }

  before(:each) do
    assign(:recommendations, [
      Recommendation.create!(
        :is_obligatory => false,
        :user => user,
        :course => course,
        :text => "Text"
      ),
      Recommendation.create!(
        :is_obligatory => false,
        :user => user,
        :course => course,
        :text => "Text"
      )
    ])
  end

  it "renders a list of recommendations" do
    render
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => user.to_s, :count => 2
    assert_select "tr>td", :text => course.to_s, :count => 2
    assert_select "tr>td", :text => "Text", :count => 2
  end
end
