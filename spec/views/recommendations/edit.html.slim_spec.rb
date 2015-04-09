require 'rails_helper'

RSpec.describe "recommendations/edit", :type => :view do
  before(:each) do
    @recommendation = assign(:recommendation, Recommendation.create!(
      :is_obligatory => false,
      :user => nil,
      :course => nil,
      :text => nil
    ))
  end

  it "renders the edit recommendation form" do
    render

    assert_select "form[action=?][method=?]", recommendation_path(@recommendation), "post" do

      assert_select "input#recommendation_is_obligatory[name=?]", "recommendation[is_obligatory]"

      assert_select "input#recommendation_related_user_ids[name=?]", "recommendation[related_user_ids]"

      assert_select "input#recommendation_related_group_ids[name=?]", "recommendation[related_group_ids]"

      assert_select "input#recommendation_course_id[name=?]", "recommendation[course_id]"

      assert_select "textarea#recommendation_text[name=?]", "recommendation[text]"
    end
  end
end
