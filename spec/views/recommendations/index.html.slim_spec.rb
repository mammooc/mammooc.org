require 'rails_helper'

RSpec.describe "recommendations/index", :type => :view do
  before(:each) do
    assign(:recommendations, [
      Recommendation.create!(
        :is_obligatory => false,
        :user => nil,
        :group => nil,
        :course => nil
      ),
      Recommendation.create!(
        :is_obligatory => false,
        :user => nil,
        :group => nil,
        :course => nil
      )
    ])
  end

  it "renders a list of recommendations" do
    pending
    render
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
