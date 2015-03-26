require 'rails_helper'

RSpec.describe "groups/members", :type => :view do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @second_user = FactoryGirl.create(:user)
    @third_user = FactoryGirl.create(:user)
    @group = FactoryGirl.create(:group, users: [@user, @second_user, @third_user])
    UserGroup.set_is_admin(@group.id, @user.id, true)

    sign_in @user

    @sorted_group_users = @group.users - [@user]
    @sorted_group_admins = [@user]
  end

  it "show all members of group" do
    render
    @group.users.each do |user|
      expect(rendered).to have_content user.first_name
      expect(rendered).to have_content user.last_name
    end
  end
end
