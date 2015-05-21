FactoryGirl.define do
  factory :user_identity do
    user nil
    omniauth_provider 'MyString'
    provider_user_id 'MyString'
  end
end
