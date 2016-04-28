# encoding: utf-8
# frozen_string_literal: true

FactoryGirl.define do
  factory :bookmark do
    user { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
  end
end
