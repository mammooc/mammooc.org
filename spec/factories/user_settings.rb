# encoding: utf-8
# frozen_string_literal: true

FactoryGirl.define do
  factory :user_setting do
    sequence(:name) {|n| "my_setting_#{n}" }
    association :user, factory: :user
  end
end
