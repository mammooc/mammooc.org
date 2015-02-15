require 'rails_helper'

RSpec.describe "groups/show", :type => :view do

  before(:each) do
    @group = FactoryGirl.create(:group)
    UserGroup.set_is_admin(@group.id, @group.users.first.id, true)
    @admins = @group.users
  end

  it "renders attributes in <p>" do
    render
    admin_name = @group.users.first.first_name + ' ' + @group.users.first.last_name
    expect(rendered).to match(@group.name)
    expect(rendered).to match(@group.description)
    expect(rendered).to match(admin_name)
  end
end
