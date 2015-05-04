# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe Group, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:second_user) { FactoryGirl.create(:user) }
  let!(:group) { FactoryGirl.create(:group, users: [user, second_user]) }
  let!(:group_invitation) { FactoryGirl.create(:group_invitation, group: group) }
  let!(:second_group_invitation) { FactoryGirl.create(:group_invitation, group: group) }

  it "deletes all memberships of a group and it's invitation" do
    expect(UserGroup.where(user: user, group: group)).to be_present
    expect(UserGroup.where(user: second_user, group: group)).to be_present
    expect(GroupInvitation.where(group: group).count).to eq 2
    expect { group.destroy }.not_to raise_error
    expect(UserGroup.where(user: user, group: group)).to be_empty
    expect(UserGroup.where(user: second_user, group: group)).to be_empty
    expect(GroupInvitation.where(group: group).count).to eq 0
  end
end
