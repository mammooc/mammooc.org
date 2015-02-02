FactoryGirl.define do

  factory :user do
    first_name 'Max'
    last_name 'Mustermann'
    email 'max.mustermann@example.com'
    password '12345678'
  end

end