FactoryGirl.define do
  factory :full_evaluation, class: Evaluation do
    rating { rand(1..5) }
    description 'Blub'
    user { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
    course_status :enrolled
    rated_anonymously false
    total_feedback_count { rand(1..2) }
    positive_feedback_count { rand(0..1) }
  end

  factory :minimal_evaluation, class: Evaluation do
    rating { rand(1..5) }
    user { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
    course_status :enrolled
    rated_anonymously true
  end
end
