FactoryGirl.define do

  factory :mooc_provider do
    sequence(:name) { |n| "open_mammooc#{n}" }
    logo_id 'logo_open_mammooc.png'
  end
end
