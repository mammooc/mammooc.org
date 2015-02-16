FactoryGirl.define do
  factory :group_invitation do
    association :group_id, factory: :group
    sequence(:token) { SecureRandom.urlsafe_base64(16)}
    expiry_date 1.week.from_now.in_time_zone
    used false
  end

end
