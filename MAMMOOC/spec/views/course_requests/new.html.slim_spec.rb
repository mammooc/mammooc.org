require 'rails_helper'

RSpec.describe "course_requests/new", :type => :view do
  before(:each) do
    assign(:course_request, CourseRequest.new(
      :description => "MyText",
      :course => nil,
      :user => nil,
      :group => nil
    ))
  end

  it "renders new course_request form" do
    render

    assert_select "form[action=?][method=?]", course_requests_path, "post" do

      assert_select "textarea#course_request_description[name=?]", "course_request[description]"

      assert_select "input#course_request_course_id[name=?]", "course_request[course_id]"

      assert_select "input#course_request_user_id[name=?]", "course_request[user_id]"

      assert_select "input#course_request_group_id[name=?]", "course_request[group_id]"
    end
  end
end
