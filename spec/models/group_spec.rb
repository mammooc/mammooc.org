# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'destroy group' do
    let(:user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let!(:group) { FactoryGirl.create(:group, users: [user, second_user]) }
    let!(:second_group) { FactoryGirl.create(:group, users: [user, second_user]) }
    let!(:group_invitation) { FactoryGirl.create(:group_invitation, group: group) }
    let!(:second_group_invitation) { FactoryGirl.create(:group_invitation, group: group) }

    it 'deletes all memberships of a group and its invitation' do
      expect(UserGroup.where(user: user, group: group)).to be_present
      expect(UserGroup.where(user: second_user, group: group)).to be_present
      expect(GroupInvitation.where(group: group).count).to eq 2
      expect { group.destroy }.not_to raise_error
      expect(UserGroup.where(user: user, group: group)).to be_empty
      expect(UserGroup.where(user: second_user, group: group)).to be_empty
      expect(GroupInvitation.where(group: group).count).to eq 0
    end

    it 'deletes group and delete group from all activities of group' do
      activity1 = FactoryGirl.create(:activity_bookmark, user_ids: [second_user.id], group_ids: [group.id, second_group.id])
      activity2 = FactoryGirl.create(:activity_bookmark, user_ids: [user.id, second_user.id], group_ids: [group.id])
      FactoryGirl.create(:activity_bookmark, user_ids: [], group_ids: [group.id])

      expect(PublicActivity::Activity.count).to eq 3
      expect { group.destroy! }.not_to raise_error
      expect(PublicActivity::Activity.count).to eq 2
      expect(activity1.reload.user_ids).to match_array([second_user.id])
      expect(activity1.reload.group_ids).to match_array([second_group.id])
      expect(activity2.reload.user_ids).to match_array([user.id, second_user.id])
      expect(activity2.reload.group_ids).to match_array([])
    end

    it 'deletes group and all recommendations of group' do
      FactoryGirl.create(:group_recommendation, group: group, users: group.users)
      FactoryGirl.create(:group_recommendation, group: group, users: group.users)
      FactoryGirl.create(:group_recommendation, group: second_group, users: second_group.users)

      expect(Recommendation.count).to eq 3
      expect { group.destroy! }.not_to raise_error
      expect(Recommendation.count).to eq 1
    end
  end

  describe 'user_ids' do
    let(:user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let!(:group) { FactoryGirl.create(:group, users: [user, second_user]) }

    it 'returns an array with all ids of group_members' do
      expect(group.user_ids).to include(user.id)
      expect(group.user_ids).to include(second_user.id)
    end
  end

  describe 'admins' do
    let(:user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let(:third_user) { FactoryGirl.create(:user) }
    let(:group) do
      group = FactoryGirl.create(:group, users: [user, second_user, third_user])
      UserGroup.set_is_admin(group.id, user.id, true)
      UserGroup.set_is_admin(group.id, second_user.id, true)
      group
    end

    it 'returns all admins of a group' do
      admins = group.admins
      expect(admins).to match_array User.find(user.id, second_user.id)
    end
  end

  describe 'average enrollments' do
    let(:course1) { FactoryGirl.create(:course) }
    let(:course2) { FactoryGirl.create(:course) }
    let(:course3) { FactoryGirl.create(:course) }
    let!(:course4) { FactoryGirl.create(:course) }
    let(:user) { FactoryGirl.create(:user, courses: [course1, course2, course3]) }
    let(:second_user) { FactoryGirl.create(:user, courses: [course2, course3]) }
    let(:third_user) { FactoryGirl.create(:user, courses: [course3]) }
    let(:fourth_user) { FactoryGirl.create(:user, courses: [course4]) }
    let(:group) { FactoryGirl.create(:group, users: [user, second_user, third_user, fourth_user]) }
    let(:group2) { FactoryGirl.create(:group, users: []) }
    let(:user_setting) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: user) }
    let!(:user_setting_entry) { FactoryGirl.create(:user_setting_entry, setting: user_setting, key: 'groups', value: [group.id]) }
    let(:user_setting2) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: second_user) }
    let!(:user_setting_entry2) { FactoryGirl.create(:user_setting_entry, setting: user_setting2, key: 'groups', value: [group.id]) }
    let(:user_setting3) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: third_user) }
    let!(:user_setting_entry3) { FactoryGirl.create(:user_setting_entry, setting: user_setting3, key: 'groups', value: [group.id]) }

    it 'returns average of all course enrollments per group member' do
      average = group.average_enrollments
      expect(average).to eq 2
      average2 = group2.average_enrollments
      expect(average2).to eq 0
    end

    it 'returns a float with two decimal places' do
      third_user.courses = []
      average = group.average_enrollments
      expect(average).to eq 1.67
    end
  end

  describe 'enrolled courses with amount' do
    let(:course1) { FactoryGirl.create(:course) }
    let(:course2) { FactoryGirl.create(:course) }
    let(:course3) { FactoryGirl.create(:course) }
    let!(:course4) { FactoryGirl.create(:course) }
    let!(:course5) { FactoryGirl.create(:course) }
    let(:user) { FactoryGirl.create(:user, courses: [course1, course2, course3]) }
    let(:second_user) { FactoryGirl.create(:user, courses: [course2, course3]) }
    let(:third_user) { FactoryGirl.create(:user, courses: [course3]) }
    let(:fourth_user) { FactoryGirl.create(:user, courses: [course4]) }
    let(:group) { FactoryGirl.create(:group, users: [user, second_user, third_user, fourth_user]) }
    let(:user_setting) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: user) }
    let!(:user_setting_entry) { FactoryGirl.create(:user_setting_entry, setting: user_setting, key: 'groups', value: [group.id]) }
    let(:user_setting2) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: second_user) }
    let!(:user_setting_entry2) { FactoryGirl.create(:user_setting_entry, setting: user_setting2, key: 'groups', value: [group.id]) }
    let(:user_setting3) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: third_user) }
    let!(:user_setting_entry3) { FactoryGirl.create(:user_setting_entry, setting: user_setting3, key: 'groups', value: [group.id]) }

    it 'returns all enrolled course and total number of enrollments of group members for all member who share course enrollments' do
      enrolled_courses = group.enrolled_courses_with_amount
      expect(enrolled_courses).to match_array([{course: course1, count: 1}, {course: course2, count: 2}, {course: course3, count: 3}])
      expect(enrolled_courses).not_to include(course4)
    end
  end

  describe 'enrolled courses' do
    let(:course1) { FactoryGirl.create(:course) }
    let(:course2) { FactoryGirl.create(:course) }
    let(:course3) { FactoryGirl.create(:course) }
    let!(:course4) { FactoryGirl.create(:course) }
    let!(:course5) { FactoryGirl.create(:course) }
    let(:user) { FactoryGirl.create(:user, courses: [course1, course2, course3]) }
    let(:second_user) { FactoryGirl.create(:user, courses: [course2, course3]) }
    let(:third_user) { FactoryGirl.create(:user, courses: [course3]) }
    let(:fourth_user) { FactoryGirl.create(:user, courses: [course4]) }
    let(:group) { FactoryGirl.create(:group, users: [user, second_user, third_user, fourth_user]) }
    let(:user_setting) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: user) }
    let!(:user_setting_entry) { FactoryGirl.create(:user_setting_entry, setting: user_setting, key: 'groups', value: [group.id]) }
    let(:user_setting2) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: second_user) }
    let!(:user_setting_entry2) { FactoryGirl.create(:user_setting_entry, setting: user_setting2, key: 'groups', value: [group.id]) }
    let(:user_setting3) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: third_user) }
    let!(:user_setting_entry3) { FactoryGirl.create(:user_setting_entry, setting: user_setting3, key: 'groups', value: [group.id]) }

    it 'returns all enrolled courses from users who share their data' do
      enrolled_courses = group.enrolled_courses
      expect(enrolled_courses).to match_array([course1, course2, course3])
      expect(enrolled_courses).not_to include(course4)
    end
  end

  describe 'number_of_users_who_share_course_enrollments' do
    let(:user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let(:third_user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }
    let(:user_setting) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: user) }
    let!(:user_setting_entry) { FactoryGirl.create(:user_setting_entry, setting: user_setting, key: 'groups', value: [group.id]) }
    let(:user_setting2) { FactoryGirl.create(:user_setting, name: :course_enrollments_visibility, user: second_user) }
    let!(:user_setting_entry2) { FactoryGirl.create(:user_setting_entry, setting: user_setting2, key: 'groups', value: [group.id]) }
    let(:user_setting3) { FactoryGirl.create(:user_setting, name: :course_results_visibility, user: third_user) }
    let!(:user_setting_entry3) { FactoryGirl.create(:user_setting_entry, setting: user_setting3, key: 'groups', value: [group.id]) }

    it 'returns the number of group members who share their course enrollments with the group' do
      expect(group.number_of_users_who_share_course_enrollments).to eq 2
    end
  end
end
