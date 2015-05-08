# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe User, type: :model do

  let!(:user) { FactoryGirl.create(:user) }
  let(:second_user) { FactoryGirl.create(:user) }
  let(:third_user) { FactoryGirl.create(:user) }
  let(:one_member_group) { FactoryGirl.create(:group, users: [user])}
  let(:many_members_group) { FactoryGirl.create(:group, users: [user,second_user,third_user])}


  describe 'should handle Groups when destroyed' do
    it 'should delete a user' do
      user_count = User.all.count
      expect(user.destroy).to be_truthy
      expect(User.all.count).to eql(user_count-1)
    end

    it 'should delete the user and group when user is last member' do
      UserGroup.set_is_admin(one_member_group.id, user.id, true)
      group_count = Group.all.count
      expect(user.destroy).to be_truthy
      expect(Group.all.count).to eql(group_count-1)
    end

    it 'should delete the user when user is one of many admins' do
      UserGroup.set_is_admin(many_members_group.id, user.id, true)
      UserGroup.set_is_admin(many_members_group.id, second_user.id, true)
      group_count = Group.all.count
      expect(user.destroy).to be_truthy
      expect(Group.all.count).to eql(group_count)
    end

    it 'should not delete the user when user is last admin and there are other members in group ' do
      UserGroup.set_is_admin(many_members_group.id, user.id, true)
      group_count = Group.all.count
      user_count = User.all.count
      expect(user.destroy).to be_falsey
      expect(User.all.count).to eql(user_count)
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
end
