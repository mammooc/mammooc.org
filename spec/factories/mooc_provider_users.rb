# frozen_string_literal: true

FactoryGirl.define do
  factory :naive_mooc_provider_user, class: MoocProviderUser do
    association :user_id, factory: :user
    association :mooc_provider_id, factory: :mooc_provider
    sequence(:access_token) {|n| "token#{n}" }
  end

  factory :oauth_mooc_provider_user, class: MoocProviderUser do
    association :user_id, factory: :user
    association :mooc_provider_id, factory: :mooc_provider
    sequence(:access_token) {|n| "token#{n}" }
    access_token_valid_until { Time.zone.now + 5.minutes }
  end
end
