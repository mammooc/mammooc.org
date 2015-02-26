FactoryGirl.define do

  factory :user do
    first_name 'Max'
    last_name 'Mustermann'
    sequence(:email) { |n| "max.mustermann#{n}@example.com" }
    password '12345678'
  end

  factory :fullUser, class: User do
    first_name 'Maximus'
    last_name 'Mustermannnus'
    email 'maximus.mustermannus@example.com'
    password '12345678'
    gender 'Titan'
    profile_image_id '42'
    about_me 'Sieh mich an und erstarre!'
  end


end