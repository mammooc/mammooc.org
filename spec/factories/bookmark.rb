# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :bookmark do
    association :user_id, factory: :user
    association :course_id, factory: :course
  end
end