require 'rails_helper'

RSpec.describe "groups/show", :type => :view do
  let(:user) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group, users: [user]) }
  let(:group_admins) { group.users }
  let(:group_users) { group.users }
  let(:ordered_group_members) { group.users }
  let(:recommendation) { FactoryGirl.create(:group_recommendation, group: group) }

  before(:each) do
    @group = group
    UserGroup.set_is_admin(group.id, user.id, true)
    @recommendations = [recommendation]
    @provider_logos = {}
    @group_picture = {}
    @profile_pictures = {}
    sign_in user
  end

  it "renders attributes in <p>" do
    render
    admin_name = group.users.first.first_name + ' ' + group.users.first.last_name
    expect(rendered).to match(group.description)
  end
end
