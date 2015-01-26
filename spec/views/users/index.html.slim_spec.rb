require 'rails_helper'

RSpec.describe "users/index", :type => :view do
  before(:each) do
    pending
    assign(:users, [
      User.create!(
        :first_name => "First Name",
        :last_name => "Last Name",
        :gender => "Gender",
        :profile_image_id => "Profile Image",
        :about_me => "MyText"
      ),
      User.create!(
        :first_name => "First Name",
        :last_name => "Last Name",
        :gender => "Gender",
        :profile_image_id => "Profile Image",
        :about_me => "MyText"
      )
    ])
  end

  it "renders a list of users" do
    pending
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Gender".to_s, :count => 2
    assert_select "tr>td", :text => "Profile Image".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
