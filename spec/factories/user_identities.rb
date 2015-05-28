FactoryGirl.define do
  factory :user_identity do
    user
    omniauth_provider 'open_provider'
    sequence(:provider_user_id) {|n| "User_#{n}" }
  end
end
