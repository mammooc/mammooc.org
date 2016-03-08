# encoding: utf-8
# frozen_string_literal: true

FactoryGirl.define do
  factory :group_invitation do
    association :group_id, factory: :group
    sequence(:token) { SecureRandom.urlsafe_base64(Settings.token_length) }
    expiry_date Settings.token_expiry_date
    used false
  end
end
