FactoryGirl.define do

  factory :user do
    first_name 'Max'
    last_name 'Mustermann'
    sequence(:email) { |n| "max.mustermann#{n}@example.com" }
    password '12345678'
  end

end