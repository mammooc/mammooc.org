require 'rails_helper'

RSpec.describe "progresses/edit", :type => :view do
  before(:each) do
    @progress = assign(:progress, Progress.create!(
      :percentage => 1.5,
      :permissions => "MyString",
      :course => nil,
      :user => nil
    ))
  end

  it "renders the edit progress form" do
    render

    assert_select "form[action=?][method=?]", progress_path(@progress), "post" do

      assert_select "input#progress_percentage[name=?]", "progress[percentage]"

      assert_select "input#progress_permissions[name=?]", "progress[permissions]"

      assert_select "input#progress_course_id[name=?]", "progress[course_id]"

      assert_select "input#progress_user_id[name=?]", "progress[user_id]"
    end
  end
end
