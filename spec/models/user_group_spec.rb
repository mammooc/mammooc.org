require 'rails_helper'

RSpec.describe UserGroup, :type => :model do

  let(:user) {FactoryGirl.create(:user)}
  let(:group) {FactoryGirl.create(:group, users: [user])}

  describe "set is admin" do
    it "should set attribute is_admin to true" do
      UserGroup.set_is_admin(group.id, user.id, true)
      admin_ids = UserGroup.where(group_id: group.id, is_admin: true).collect{|user_groups| user_groups.user_id}
      expect(admin_ids).to include(user.id)
    end

    it "should set attribute is_admin to false" do
      UserGroup.set_is_admin(group.id, user.id, true)
      UserGroup.set_is_admin(group.id, user.id, false)
      admin_ids = UserGroup.where(group_id: group.id, is_admin: true).collect{|user_groups| user_groups.user_id}
      expect(admin_ids).not_to include(user.id)
    end

  end

end
