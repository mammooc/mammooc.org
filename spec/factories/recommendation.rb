# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :user_recommendation, class: Recommendation do
    is_obligatory false
    author { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
    text 'Great Course!'
    users { [FactoryGirl.create(:user)] }
    after(:create) {|recommendation| FactoryGirl.create(:activity_user_recommendation, key: 'recommendation.create', trackable_id: recommendation.id, trackable_type: 'Recommendation', owner: recommendation.author, group_ids: nil, user_ids: recommendation.users.collect(&:id)) }
  end

  factory :group_recommendation, class: Recommendation do
    is_obligatory false
    author { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
    group { FactoryGirl.create(:group) }
    text 'Great Course!'
    users { [FactoryGirl.create(:user), FactoryGirl.create(:user)] }
    after(:create) {|recommendation| FactoryGirl.create(:activity_group_recommendation, key: 'recommendation.create', trackable_id: recommendation.id, trackable_type: 'Recommendation', owner: recommendation.author, group_ids: [recommendation.group.id], user_ids: recommendation.group.user_ids) }
  end

  factory :user_recommendation_without_activity, class: Recommendation do
    is_obligatory false
    author { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
    text 'Great Course!'
    users { [FactoryGirl.create(:user)] }
  end

  factory :group_recommendation_without_activity, class: Recommendation do
    is_obligatory false
    author { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
    group { FactoryGirl.create(:group) }
    text 'Great Course!'
    users { [FactoryGirl.create(:user), FactoryGirl.create(:user)] }
  end
end
