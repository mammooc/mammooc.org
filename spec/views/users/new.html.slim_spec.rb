require 'rails_helper'

RSpec.describe "users/new", :type => :view do
  before(:each) do
    assign(:user, User.new(
      :id => "",
      :firstName => "MyString",
      :lastName => "MyString",
      :title => "MyString",
      :password => "MyString",
      :profileImageId => "MyString",
      :emailSettings => "",
      :aboutMe => "MyText"
    ))
  end

  it "renders new user form" do
    render

    assert_select "form[action=?][method=?]", users_path, "post" do

      assert_select "input#user_id[name=?]", "user[id]"

      assert_select "input#user_firstName[name=?]", "user[firstName]"

      assert_select "input#user_lastName[name=?]", "user[lastName]"

      assert_select "input#user_title[name=?]", "user[title]"

      assert_select "input#user_password[name=?]", "user[password]"

      assert_select "input#user_profileImageId[name=?]", "user[profileImageId]"

      assert_select "input#user_emailSettings[name=?]", "user[emailSettings]"

      assert_select "textarea#user_aboutMe[name=?]", "user[aboutMe]"
    end
  end
end
