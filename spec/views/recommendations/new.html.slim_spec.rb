require 'rails_helper'

RSpec.describe "recommendations/new", :type => :view do
  before(:each) do
    assign(:recommendation, Recommendation.new(
      :is_obligatory => false,
      :user => nil,
      :group => nil,
      :course => nil
    ))
  end

  it "renders new recommendation form" do
    render

    assert_select "form[action=?][method=?]", recommendations_path, "post" do

      assert_select "input#recommendation_is_obligatory[name=?]", "recommendation[is_obligatory]"

      assert_select "input#recommendation_user_id[name=?]", "recommendation[user_id]"

      assert_select "input#recommendation_group_id[name=?]", "recommendation[group_id]"

      assert_select "input#recommendation_course_id[name=?]", "recommendation[course_id]"
    end
  end
end
