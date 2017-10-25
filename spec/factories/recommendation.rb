# frozen_string_literal: true

FactoryBot.define do
  factory :user_recommendation, class: Recommendation do
    is_obligatory false
    author { FactoryBot.create(:user) }
    course { FactoryBot.create(:course) }
    text 'Great Course!'
    users { [FactoryBot.create(:user)] }
    after(:create) {|recommendation| FactoryBot.create(:activity, key: 'recommendation.create', trackable_id: recommendation.id, trackable_type: 'Recommendation', owner: recommendation.author, group_ids: nil, user_ids: recommendation.users.collect(&:id)) }
  end

  factory :group_recommendation, class: Recommendation do
    is_obligatory false
    author { FactoryBot.create(:user) }
    course { FactoryBot.create(:course) }
    group { FactoryBot.create(:group) }
    text 'Great Course!'
    users { [FactoryBot.create(:user), FactoryBot.create(:user)] }
    after(:create) {|recommendation| FactoryBot.create(:activity, key: 'recommendation.create', trackable_id: recommendation.id, trackable_type: 'Recommendation', owner: recommendation.author, group_ids: [recommendation.group.id], user_ids: recommendation.group.user_ids) }
  end

  factory :user_recommendation_without_activity, class: Recommendation do
    is_obligatory false
    author { FactoryBot.create(:user) }
    course { FactoryBot.create(:course) }
    text 'Great Course!'
    users { [FactoryBot.create(:user)] }
  end

  factory :group_recommendation_without_activity, class: Recommendation do
    is_obligatory false
    author { FactoryBot.create(:user) }
    course { FactoryBot.create(:course) }
    group { FactoryBot.create(:group) }
    text 'Great Course!'
    users { [FactoryBot.create(:user), FactoryBot.create(:user)] }
  end
end
