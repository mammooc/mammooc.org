FactoryGirl.define do

  factory :mooc_provider do
    sequence(:name) { |n| "testProvider#{n}" }
  end
end