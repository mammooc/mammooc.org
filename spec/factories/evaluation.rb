# frozen_string_literal: true

FactoryBot.define do
  factory :full_evaluation, class: 'Evaluation' do
    rating { rand(1..5) }
    description { 'Blub' }
    user { FactoryBot.create(:user) }
    course { FactoryBot.create(:course) }
    course_status { :enrolled }
    rated_anonymously { false }
    total_feedback_count { rand(1..2) }
    positive_feedback_count { rand(0..1) }
  end

  factory :minimal_evaluation, class: 'Evaluation' do
    rating { rand(1..5) }
    user { FactoryBot.create(:user) }
    course { FactoryBot.create(:course) }
    course_status { :enrolled }
    rated_anonymously { true }
  end
end
