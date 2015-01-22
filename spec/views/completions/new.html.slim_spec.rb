require 'rails_helper'

RSpec.describe "completions/new", :type => :view do
  before(:each) do
    assign(:completion, Completion.new(
      :position_in_course => 1,
      :points => 1.5,
      :permissions => "",
      :user => nil,
      :course => nil
    ))
  end

  it "renders new completion form" do
    pending
    render

    assert_select "form[action=?][method=?]", completions_path, "post" do

      assert_select "input#completion_position_in_course[name=?]", "completion[position_in_course]"

      assert_select "input#completion_points[name=?]", "completion[points]"

      assert_select "input#completion_permissions[name=?]", "completion[permissions]"

      assert_select "input#completion_user_id[name=?]", "completion[user_id]"

      assert_select "input#completion_course_id[name=?]", "completion[course_id]"
    end
  end
end
