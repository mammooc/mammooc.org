# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :activity, class: PublicActivity::Activity do
    user_ids { [FactoryGirl.create(:user).id, FactoryGirl.create(:user).id] }
    group_ids { [FactoryGirl.create(:group).id] }
    trackable_id { FactoryGirl.create(:group_recommendation).id }
    trackable_type 'Recommendation'
    owner_id { FactoryGirl.create(:user).id }
    owner_type 'User'
  end
end
