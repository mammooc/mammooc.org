# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :mooc_provider_user do
    association :user_id, factory: :user
    association :mooc_provider_id, factory: :mooc_provider
    sequence(:authentication_token) {|n| "token#{n}" }
  end
end
