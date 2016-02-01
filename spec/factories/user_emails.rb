# encoding: utf-8
# frozen_string_literal: true

FactoryGirl.define do
  factory :user_email do
    sequence(:address) {|n| "max.mustermann#{n}@example.com" }
    is_verified false
    is_primary true
    user
  end
end
