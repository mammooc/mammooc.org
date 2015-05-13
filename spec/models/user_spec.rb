# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { FactoryGirl.create(:user) }
  let(:second_user) { FactoryGirl.create(:user) }
  let(:third_user) { FactoryGirl.create(:user) }
  let(:one_member_group) { FactoryGirl.create(:group, users: [user]) }
  let(:many_members_group) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }

  describe 'handles Groups when destroyed' do
    it 'deletes a user' do
      user_count = described_class.count
      expect(user.destroy).to be_truthy
      expect(described_class.count).to eql(user_count - 1)
    end

    it 'deletes the user and group when user is last member' do
      UserGroup.set_is_admin(one_member_group.id, user.id, true)
      group_count = Group.all.count
      expect(user.destroy).to be_truthy
      expect(Group.all.count).to eql(group_count - 1)
    end

    it 'deletes the user when user is one of many admins' do
      UserGroup.set_is_admin(many_members_group.id, user.id, true)
      UserGroup.set_is_admin(many_members_group.id, second_user.id, true)
      group_count = Group.all.count
      expect(user.destroy).to be_truthy
      expect(Group.all.count).to eql(group_count)
    end

    it 'does not delete the user when user is last admin and there are other members in group ' do
      UserGroup.set_is_admin(many_members_group.id, user.id, true)
      group_count = Group.all.count
      user_count = described_class.count
      expect(user.destroy).to be_falsey
      expect(described_class.count).to eql(user_count)
      expect(Group.all.count).to eql(group_count)
    end
  end

  it 'has valid factory' do
    expect(FactoryGirl.build_stubbed(:user)).to be_valid
  end

  it 'requires first name' do
    expect(FactoryGirl.build_stubbed(:user, first_name: '')).not_to be_valid
  end

  it 'requires last name' do
    expect(FactoryGirl.build_stubbed(:user, last_name: '')).not_to be_valid
  end

  it 'requires email' do
    expect(FactoryGirl.build_stubbed(:user, email: '')).not_to be_valid
  end

  describe 'common_groups_with_user(other_user)' do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    it 'should only display common groups' do
      group1 = FactoryGirl.create(:group, users: [user])
      group2 = FactoryGirl.create(:group, users: [user, other_user])
      expect(user.common_groups_with_user(other_user)).to match([group2])
    end

    it 'should display all groups if they are equal' do
      group1 = FactoryGirl.create(:group, users: [user, other_user])
      group2 = FactoryGirl.create(:group, users: [user, other_user])
      expect(user.common_groups_with_user(other_user)).to match_array([group1, group2])
    end

    it 'should be empty if there are no common groups' do
      group1 = FactoryGirl.create(:group, users: [user])
      group2 = FactoryGirl.create(:group, users: [other_user])
      expect(user.common_groups_with_user(other_user)).to match([])
    end

  end
end
