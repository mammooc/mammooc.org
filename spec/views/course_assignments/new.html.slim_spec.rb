require 'rails_helper'

RSpec.describe "course_assignments/new", :type => :view do
  before(:each) do
    assign(:course_assignment, CourseAssignment.new(
      :name => "MyString",
      :maximum_score => 1.5,
      :average_score => 1.5,
      :course => nil
    ))
  end

  it "renders new course_assignment form" do
    render

    assert_select "form[action=?][method=?]", course_assignments_path, "post" do

      assert_select "input#course_assignment_name[name=?]", "course_assignment[name]"

      assert_select "input#course_assignment_maximum_score[name=?]", "course_assignment[maximum_score]"

      assert_select "input#course_assignment_average_score[name=?]", "course_assignment[average_score]"

      assert_select "input#course_assignment_course_id[name=?]", "course_assignment[course_id]"
    end
  end
end
