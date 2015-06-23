# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :bookmark do
    user { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
  end
end
