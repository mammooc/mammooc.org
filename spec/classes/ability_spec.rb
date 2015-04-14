require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject(:ability) { Ability.new(user) }
  let(:user) { nil }
  describe 'Groups' do
    let (:user) { FactoryGirl.create :user }
    let(:group_without_user) { FactoryGirl.create :group }
    let(:group_with_user) { FactoryGirl.create :group, users: [user] }
    let(:group_with_admin) {
      g = FactoryGirl.create :group, users: [user]
      UserGroup.set_is_admin(g.id, user.id, true)
      g
    }

    describe 'read' do
      it { should be_able_to(:read, group_with_user) }
      it { should be_able_to(:read, group_with_admin) }
      it { should_not be_able_to(:read, group_without_user) }
    end

    describe 'create' do
      it { should be_able_to(:create, Group) }
    end

    describe 'update' do
      it { should be_able_to(:update, group_with_admin) }
      it { should_not be_able_to(:update, group_without_user) }
      it { should_not be_able_to(:update, group_with_user) }
    end

    describe 'destroy' do
      it { should be_able_to(:destroy, group_with_admin) }
      it { should_not be_able_to(:destroy, group_without_user) }
      it { should_not be_able_to(:destroy, group_with_user) }
    end

    describe 'join' do
      it { should be_able_to(:join, Group) }
    end

    describe 'members' do
      it { should be_able_to(:members, group_with_user) }
      it { should be_able_to(:members, group_with_admin) }
      it { should_not be_able_to(:members, group_without_user) }
    end

    describe 'admins' do
      it { should be_able_to(:admins, group_with_user) }
      it { should be_able_to(:admins, group_with_admin) }
      it { should_not be_able_to(:admins, group_without_user) }
    end

    describe 'leave' do
      it { should be_able_to(:leave, group_with_user) }
      it { should be_able_to(:leave, group_with_admin) }
      it { should_not be_able_to(:leave, group_without_user) }
    end

    describe 'condition_for_changing_member_status' do
      it { should be_able_to(:condition_for_changing_member_status, group_with_admin) }
      it { should be_able_to(:condition_for_changing_member_status, group_with_user) }
      it { should_not be_able_to(:condition_for_changing_member_status, group_without_user) }
    end

    describe 'invite_group_members' do
      it { should be_able_to(:invite_group_members, group_with_admin) }
      it { should_not be_able_to(:invite_group_members, group_without_user) }
      it { should_not be_able_to(:invite_group_members, group_with_user) }
    end

    describe 'add_administrator' do
      it { should be_able_to(:add_administrator, group_with_admin) }
      it { should_not be_able_to(:add_administrator, group_without_user) }
      it { should_not be_able_to(:add_administrator, group_with_user) }
    end

    describe 'demote_administrator' do
      it { should be_able_to(:demote_administrator, group_with_admin) }
      it { should_not be_able_to(:demote_administrator, group_without_user) }
      it { should_not be_able_to(:demote_administrator, group_with_user) }
    end

    describe 'remove_group_member' do
      it { should be_able_to(:remove_group_member, group_with_admin) }
      it { should_not be_able_to(:remove_group_member, group_without_user) }
      it { should_not be_able_to(:remove_group_member, group_with_user) }
    end

    describe 'all_members_to_administrators' do
      it { should be_able_to(:all_members_to_administrators, group_with_admin) }
      it { should_not be_able_to(:all_members_to_administrators, group_without_user) }
      it { should_not be_able_to(:all_members_to_administrators, group_with_user) }
    end
  end
end
