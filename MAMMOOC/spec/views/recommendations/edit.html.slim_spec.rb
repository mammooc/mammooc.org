require 'rails_helper'

RSpec.describe "recommendations/edit", :type => :view do
  before(:each) do
    @recommendation = assign(:recommendation, Recommendation.create!(
      :is_obligatory => false,
      :user => nil,
      :group => nil,
      :course => nil
    ))
  end

  it "renders the edit recommendation form" do
    render

    assert_select "form[action=?][method=?]", recommendation_path(@recommendation), "post" do

      assert_select "input#recommendation_is_obligatory[name=?]", "recommendation[is_obligatory]"

      assert_select "input#recommendation_user_id[name=?]", "recommendation[user_id]"

      assert_select "input#recommendation_group_id[name=?]", "recommendation[group_id]"

      assert_select "input#recommendation_course_id[name=?]", "recommendation[course_id]"
    end
  end
end
