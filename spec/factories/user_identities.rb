# frozen_string_literal: true

FactoryGirl.define do
  factory :user_identity do
    user
    omniauth_provider 'openProvider'
    sequence(:provider_user_id) {|n| "User#{n}" }
  end
end
