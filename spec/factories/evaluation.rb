FactoryGirl.define do
  factory :full_evaluation, class: Evaluation do
    rating {rand(1..5)}
    description 'Blub'
    user {FactoryGirl.create(:user)}
    course {FactoryGirl.create(:course)}
    creation_date Time.zone.now
    update_date Time.zone.now
    course_status {rand(1..3)}
    rated_anonymously false
    evaluation_rating_count {rand(1..2)}
    evaluation_helpful_rating_count {rand(0..1)}
  end

  factory :minimal_evaluation, class: Evaluation do
    rating {rand(1..5)}
    user {FactoryGirl.create(:user)}
    course {FactoryGirl.create(:course)}
    creation_date Time.zone.now
    update_date Time.zone.now
    course_status {rand(1..3)}
    rated_anonymously true
  end

end
