require 'rails_helper'

RSpec.describe "users/show", :type => :view do
  before(:each) do
    @user = assign(:user, User.create!(
      :first_name => "First Name",
      :last_name => "Last Name",
      :title => "Title",
      :password => "Password",
      :profile_image_id => "Profile Image",
      :about_me => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Password/)
    expect(rendered).to match(/Profile Image/)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
  end
end
