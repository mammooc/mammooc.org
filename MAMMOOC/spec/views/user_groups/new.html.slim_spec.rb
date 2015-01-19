require 'rails_helper'

RSpec.describe "user_groups/new", :type => :view do
  before(:each) do
    assign(:user_group, UserGroup.new(
      :is_admin => false,
      :user => nil,
      :group => nil
    ))
  end

  it "renders new user_group form" do
    render

    assert_select "form[action=?][method=?]", user_groups_path, "post" do

      assert_select "input#user_group_is_admin[name=?]", "user_group[is_admin]"

      assert_select "input#user_group_user_id[name=?]", "user_group[user_id]"

      assert_select "input#user_group_group_id[name=?]", "user_group[group_id]"
    end
  end
end
