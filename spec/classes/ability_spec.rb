# -*- encoding : utf-8 -*-
require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject(:ability) { described_class.new(user) }
  let(:user) { nil }

  describe 'Groups' do
    let(:user) { FactoryGirl.create :user }
    let(:group_without_user) { FactoryGirl.create :group }
    let(:group_with_user) { FactoryGirl.create :group, users: [user] }
    let(:group_with_admin) do
      group = FactoryGirl.create :group, users: [user]
      UserGroup.set_is_admin(group.id, user.id, true)
      group
    end

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
    let!(:group) { FactoryGirl.create :group, users: [second_user] }
    let!(:group_with_admin) do
      group = FactoryGirl.create :group, users: [user]
      UserGroup.set_is_admin(group.id, user.id, true)
      group
    end
    let(:recommendation_of_user) { FactoryGirl.create :user_recommendation, users: [user] }
    let(:recommendation_of_another_user) { FactoryGirl.create :user_recommendation, users: [second_user] }
    let(:recommendation_of_group) { FactoryGirl.create :group_recommendation, group: group }
    let(:recommendation_of_group_admin) { FactoryGirl.create :group_recommendation, group: group_with_admin }

    describe 'create' do
      it { is_expected.to be_able_to(:create, Recommendation.new) }
    end

    describe 'index' do
      it { is_expected.to be_able_to(:index, Recommendation.new) }
    end

    describe 'delete_user_from_recommendation' do
      it { is_expected.to be_able_to(:delete_user_from_recommendation, recommendation_of_user) }
      it { is_expected.to_not be_able_to(:delete_user_from_recommendation, recommendation_of_another_user) }
    end

    describe 'delete_group_recommendation' do
      it { is_expected.to_not be_able_to(:delete_group_recommendation, recommendation_of_group) }
      it { is_expected.to be_able_to(:delete_group_recommendation, recommendation_of_group_admin) }
    end

    describe 'create as user without groups' do
      subject(:ability) { described_class.new(third_user) }
      it { is_expected.to_not be_able_to(:create, Recommendation.new) }
    end
  end

  describe 'Users' do
    let(:user) { FactoryGirl.create :user }
    let(:another_user) { FactoryGirl.create :user }
    let(:second_user) { FactoryGirl.create :user }
    let(:user_setting) { FactoryGirl.create(:user_setting, name: :profile_visibility, user: second_user) }
    let!(:user_setting_entry) { FactoryGirl.create(:user_setting_entry, setting: user_setting, key: 'users', value: [user.id]) }
    let(:user_setting2) { FactoryGirl.create(:user_setting, name: :course_results_visibility, user: second_user) }
    let!(:user_setting_entry2) { FactoryGirl.create(:user_setting_entry, setting: user_setting2, key: 'users', value: [user.id]) }

    describe 'create' do
      it { is_expected.to_not be_able_to(:create, User) }
    end

    describe 'show' do
      it { is_expected.to be_able_to(:show, user) }
      it { is_expected.to_not be_able_to(:show, another_user) }
      it { is_expected.to be_able_to(:show, second_user) }

      context 'in user\'s groups' do
        let!(:group) { FactoryGirl.create :group, users: [user, another_user] }
        let(:user_setting) { FactoryGirl.create(:user_setting, name: :profile_visibility, user: another_user) }
        let!(:user_setting_entry) { FactoryGirl.create(:user_setting_entry, setting: user_setting, key: 'groups', value: [group.id]) }

        it { is_expected.to be_able_to(:show, another_user) }
      end
    end

    describe 'completions' do
      it { is_expected.to be_able_to(:completions, user) }
      it { is_expected.to be_able_to(:completions, second_user) }
      it { is_expected.to_not be_able_to(:completions, another_user) }
    end

    describe 'update' do
      it { is_expected.to be_able_to(:update, user) }
      it { is_expected.to_not be_able_to(:update, another_user) }
    end

    describe 'destroy' do
      it { is_expected.to be_able_to(:destroy, user) }
      it { is_expected.to_not be_able_to(:destroy, another_user) }
    end
  end
end
