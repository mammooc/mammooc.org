require 'rails_helper'

RSpec.describe "users/show", :type => :view do
  before(:each) do
    pending
    @user = assign(:user, User.create!(
      :first_name => "First Name",
      :last_name => "Last Name",
      :gender => "Gender",
      :profile_image_id => "Profile Image",
      :about_me => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    pending
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/Gender/)
    expect(rendered).to match(/Profile Image/)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
  end
end
