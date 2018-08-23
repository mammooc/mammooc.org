# frozen_string_literal: true

FactoryBot.define do
  factory :full_completion, class: Completion do
    quantile { Random.rand }
    points_achieved { (Random.rand * 100.0).round(1) }
    provider_percentage { points_achieved }
    association :user_id, factory: :user
    association :course_id, factory: :course

    after(:create) do |completion|
      create(:confirmation_of_participation, completion: completion)
      create(:record_of_achievement, completion: completion)
      create(:certificate, completion: completion)
    end

    after(:sub) do |completion|
      build_stubbed(:confirmation_of_participation, completion: completion)
      build_stubbed(:record_of_achievement, completion: completion)
      build_stubbed(:certificate, completion: completion)
    end
  end

  factory :completion, class: Completion do
    quantile { nil }
    points_achieved { nil }
    association :user_id, factory: :user
    association :course_id, factory: :course
  end
end
