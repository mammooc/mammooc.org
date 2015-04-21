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
      group = FactoryGirl.create :group, users: [user]
      UserGroup.set_is_admin(group.id, user.id, true)
      group
    }

    describe 'read' do
      it { is_expected.to be_able_to(:read, group_with_user) }
      it { is_expected.to be_able_to(:read, group_with_admin) }
      it { is_expected.to_not be_able_to(:read, group_without_user) }
    end

    describe 'create' do
      it { is_expected.to be_able_to(:create, Group) }
    end

    describe 'update' do
      it { is_expected.to be_able_to(:update, group_with_admin) }
      it { is_expected.to_not be_able_to(:update, group_without_user) }
      it { is_expected.to_not be_able_to(:update, group_with_user) }
    end

    describe 'destroy' do
      it { is_expected.to be_able_to(:destroy, group_with_admin) }
      it { is_expected.to_not be_able_to(:destroy, group_without_user) }
      it { is_expected.to_not be_able_to(:destroy, group_with_user) }
    end

    describe 'join' do
      it { is_expected.to be_able_to(:join, Group) }
    end

    describe 'members' do
      it { is_expected.to be_able_to(:members, group_with_user) }
      it { is_expected.to be_able_to(:members, group_with_admin) }
      it { is_expected.to_not be_able_to(:members, group_without_user) }
    end

    describe 'admins' do
      it { is_expected.to be_able_to(:admins, group_with_user) }
      it { is_expected.to be_able_to(:admins, group_with_admin) }
      it { is_expected.to_not be_able_to(:admins, group_without_user) }
    end

    describe 'leave' do
      it { is_expected.to be_able_to(:leave, group_with_user) }
      it { is_expected.to be_able_to(:leave, group_with_admin) }
      it { is_expected.to_not be_able_to(:leave, group_without_user) }
    end

    describe 'condition_for_changing_member_status' do
      it { is_expected.to be_able_to(:condition_for_changing_member_status, group_with_admin) }
      it { is_expected.to be_able_to(:condition_for_changing_member_status, group_with_user) }
      it { is_expected.to_not be_able_to(:condition_for_changing_member_status, group_without_user) }
    end

    describe 'invite_group_members' do
      it { is_expected.to be_able_to(:invite_group_members, group_with_admin) }
      it { is_expected.to_not be_able_to(:invite_group_members, group_without_user) }
      it { is_expected.to_not be_able_to(:invite_group_members, group_with_user) }
    end

    describe 'add_administrator' do
      it { is_expected.to be_able_to(:add_administrator, group_with_admin) }
      it { is_expected.to_not be_able_to(:add_administrator, group_without_user) }
      it { is_expected.to_not be_able_to(:add_administrator, group_with_user) }
    end

    describe 'demote_administrator' do
      it { is_expected.to be_able_to(:demote_administrator, group_with_admin) }
      it { is_expected.to_not be_able_to(:demote_administrator, group_without_user) }
      it { is_expected.to_not be_able_to(:demote_administrator, group_with_user) }
    end

    describe 'remove_group_member' do
      it { is_expected.to be_able_to(:remove_group_member, group_with_admin) }
      it { is_expected.to_not be_able_to(:remove_group_member, group_without_user) }
      it { is_expected.to_not be_able_to(:remove_group_member, group_with_user) }
    end

    describe 'all_members_to_administrators' do
      it { is_expected.to be_able_to(:all_members_to_administrators, group_with_admin) }
      it { is_expected.to_not be_able_to(:all_members_to_administrators, group_without_user) }
      it { is_expected.to_not be_able_to(:all_members_to_administrators, group_with_user) }
    end
  end

  describe 'Recommendations' do
    let!(:user) { FactoryGirl.create :user }
    let!(:second_user) { FactoryGirl.create :user }
    let!(:third_user) { FactoryGirl.create :user }
    let!(:group) { FactoryGirl.create :group, users:[second_user]}
    let!(:group_with_admin) {
      group = FactoryGirl.create :group, users: [user]
      UserGroup.set_is_admin(group.id, user.id, true)
      group
    }
    let(:recommendation_of_user) { FactoryGirl.create :recommendation, users: [user] }
    let(:recommendation_of_group) { FactoryGirl.create :recommendation, groups: [group] }
    let(:recommendation_of_group_admin) { FactoryGirl.create :recommendation, groups: [group_with_admin] }

    describe 'create' do
      it { is_expected.to be_able_to(:create, Recommendation.new) }
    end

    describe 'index' do
      it { is_expected.to be_able_to(:index, Recommendation.new) }
    end

    describe 'delete' do
      it { is_expected.to be_able_to(:delete, recommendation_of_user) }
      it { is_expected.to_not be_able_to(:delete, recommendation_of_group)}
      it { is_expected.to be_able_to(:delete, recommendation_of_group_admin)}
    end

    describe 'create as user without groups' do
      subject(:ability) { Ability.new(third_user) }
      it { is_expected.to_not be_able_to(:create, Recommendation.new) }
    end

  end

  end
