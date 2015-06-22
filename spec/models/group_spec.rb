# -*- encoding : utf-8 -*-
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
      expect(admins).to eql User.find(user.id, second_user.id)
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
    let(:group) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }

    it 'returns average of all course enrollments per group member' do
      average = group.average_enrollments
      expect(average).to eq 2
    end

    it 'returns a float with two ' do
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
    let(:user) { FactoryGirl.create(:user, courses: [course1, course2, course3]) }
    let(:second_user) { FactoryGirl.create(:user, courses: [course2, course3]) }
    let(:third_user) { FactoryGirl.create(:user, courses: [course3]) }
    let(:group) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }

    it 'returns all enrolled course and total number of enrollments of group members' do
      enrolled_courses = group.enrolled_courses_with_amount
      expect(enrolled_courses).to match_array([{course: course1, count: 1}, {course: course2, count: 2}, {course: course3, count: 3}])
    end
  end

  describe 'enrolled courses' do
    let(:course1) { FactoryGirl.create(:course) }
    let(:course2) { FactoryGirl.create(:course) }
    let(:course3) { FactoryGirl.create(:course) }
    let!(:course4) { FactoryGirl.create(:course) }
    let(:user) { FactoryGirl.create(:user, courses: [course1, course2, course3]) }
    let(:second_user) { FactoryGirl.create(:user, courses: [course2, course3]) }
    let(:third_user) { FactoryGirl.create(:user, courses: [course3]) }
    let(:group) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }

    it 'returns all enrolled courses' do
      enrolled_courses = group.enrolled_courses
      expect(enrolled_courses).to match_array([course1, course2, course3])
    end
  end
end
