require 'rails_helper'

RSpec.describe "user_assignments/edit", :type => :view do
  before(:each) do
    @user_assignment = assign(:user_assignment, UserAssignment.create!(
      :score => 1.5,
      :user => nil,
      :course => nil,
      :course_assignment => nil
    ))
  end

  it "renders the edit user_assignment form" do
    render

    assert_select "form[action=?][method=?]", user_assignment_path(@user_assignment), "post" do

      assert_select "input#user_assignment_score[name=?]", "user_assignment[score]"

      assert_select "input#user_assignment_user_id[name=?]", "user_assignment[user_id]"

      assert_select "input#user_assignment_course_id[name=?]", "user_assignment[course_id]"

      assert_select "input#user_assignment_course_assignment_id[name=?]", "user_assignment[course_assignment_id]"
    end
  end
end
