FactoryGirl.define do

  factory :mooc_provider do
    sequence(:name) { |n| "testProvider#{n}" }
    logo_id 'logo_openHPI.png'
  end
end
