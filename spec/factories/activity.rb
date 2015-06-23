# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :activity_group_join, class: PublicActivity::Activity  do
    key 'group.join'
    user_ids { [FactoryGirl.create(:user).id, FactoryGirl.create(:user).id] }
    group_ids { [FactoryGirl.create(:group).id] }
    trackable_id { group_ids.first }
    trackable_type 'Group'
    owner_id { FactoryGirl.create(:user).id }
    owner_type 'User'
  end

  factory :activity_course_enroll, class: PublicActivity::Activity  do
    key 'course.enroll'
    user_ids { [FactoryGirl.create(:user).id, FactoryGirl.create(:user).id] }
    group_ids { [FactoryGirl.create(:group).id] }
    trackable_id { FactoryGirl.create(:course).id }
    trackable_type 'Course'
    owner_id { FactoryGirl.create(:user).id }
    owner_type 'User'
  end

  factory :activity_bookmark, class: PublicActivity::Activity do
    key 'bookmark.create'
    user_ids { [FactoryGirl.create(:user).id, FactoryGirl.create(:user).id] }
    group_ids { [FactoryGirl.create(:group).id] }
    trackable_id { FactoryGirl.create(:bookmark).id }
    trackable_type 'Bookmark'
    owner_id { FactoryGirl.create(:user).id }
    owner_type 'User'
  end

  factory :activity_group_recommendation, class: PublicActivity::Activity do
    key 'recommendation.create'
    user_ids { [FactoryGirl.create(:user).id, FactoryGirl.create(:user).id] }
    group_ids { [FactoryGirl.create(:group).id] }
    trackable_id { FactoryGirl.create(:group_recommendation_without_activity).id }
    trackable_type 'Recommendation'
    owner_id { FactoryGirl.create(:user).id }
    owner_type 'User'

    after(:create) do |activity|
      activity.trackable_id = FactoryGirl.create(:group_recommendation_without_activity, group: Group.find(activity.group_ids.first)).id
      activity.save
    end
  end

  factory :activity_user_recommendation, class: PublicActivity::Activity do
    key 'recommendation.create'
    user_ids { [FactoryGirl.create(:user).id, FactoryGirl.create(:user).id]  }
    trackable_id { FactoryGirl.create(:user_recommendation_without_activity).id }
    trackable_type 'Recommendation'
    owner_id { FactoryGirl.create(:user).id }
    owner_type 'User'

    after(:create) do |activity|
      activity.trackable_id = FactoryGirl.create(:user_recommendation_without_activity, users: User.find(activity.user_ids)).id
      activity.save
    end
  end

  factory :activity, class: PublicActivity::Activity do
    user_ids { [FactoryGirl.create(:user).id, FactoryGirl.create(:user).id]  }
    owner_id { FactoryGirl.create(:user).id }
    owner_type 'User'
  end
end
