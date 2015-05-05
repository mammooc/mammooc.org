# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :user_recommendation, class: Recommendation do
    is_obligatory false
    author { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
    text 'Great Course!'
    users { [FactoryGirl.create(:user)] }
  end

  factory :group_recommendation, class: Recommendation do
    is_obligatory false
    author { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
    group { FactoryGirl.create(:group) }
    text 'Great Course!'
    users { [FactoryGirl.create(:user), FactoryGirl.create(:user)] }
  end
end
