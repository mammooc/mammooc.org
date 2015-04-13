require 'rails_helper'

RSpec.describe "groups/show", :type => :view do

  let(:group) { FactoryGirl.create(:group) }
  let(:group_admins) { group.users }
  let(:group_users) { group.users }
  let(:ordered_group_members) { group.users }
  let(:recommendation) { FactoryGirl.create(:recommendation, groups:[group]) }

  before(:each) do
    @group = group
    UserGroup.set_is_admin(group.id, group.users.first.id, true)
    @recommendations = [recommendation]
  end

  it "renders attributes in <p>" do
    render
    admin_name = group.users.first.first_name + ' ' + group.users.first.last_name
    expect(rendered).to match(group.description)
  end
end
