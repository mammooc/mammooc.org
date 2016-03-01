# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :mooc_provider do
    sequence(:name) {|n| "open_mammooc#{n}" }
    logo_id 'logo_open_mammooc.png'
    api_support_state 'nil'
    url 'https://example.com'
  end
end
