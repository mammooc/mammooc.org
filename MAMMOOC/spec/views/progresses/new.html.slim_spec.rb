require 'rails_helper'

RSpec.describe "progresses/new", :type => :view do
  before(:each) do
    assign(:progress, Progress.new(
      :percentage => 1.5,
      :permissions => "MyString",
      :course => nil,
      :user => nil
    ))
  end

  it "renders new progress form" do
    render

    assert_select "form[action=?][method=?]", progresses_path, "post" do

      assert_select "input#progress_percentage[name=?]", "progress[percentage]"

      assert_select "input#progress_permissions[name=?]", "progress[permissions]"

      assert_select "input#progress_course_id[name=?]", "progress[course_id]"

      assert_select "input#progress_user_id[name=?]", "progress[user_id]"
    end
  end
end
