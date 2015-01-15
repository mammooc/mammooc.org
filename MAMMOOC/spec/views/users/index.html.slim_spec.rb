require 'rails_helper'

RSpec.describe "users/index", :type => :view do
  before(:each) do
    assign(:users, [
      User.create!(
        :id => "",
        :firstName => "First Name",
        :lastName => "Last Name",
        :title => "Title",
        :password => "Password",
        :profileImageId => "Profile Image",
        :emailSettings => "",
        :aboutMe => "MyText"
      ),
      User.create!(
        :id => "",
        :firstName => "First Name",
        :lastName => "Last Name",
        :title => "Title",
        :password => "Password",
        :profileImageId => "Profile Image",
        :emailSettings => "",
        :aboutMe => "MyText"
      )
    ])
  end

  it "renders a list of users" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Password".to_s, :count => 2
    assert_select "tr>td", :text => "Profile Image".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
