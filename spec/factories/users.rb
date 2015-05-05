# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :user do
    sequence(:first_name) {|n| "Max_#{n}" }
    last_name 'Mustermann'
    sequence(:email) {|n| "max.mustermann#{n}@example.com" }
    password '12345678'
    profile_image_id 'profile_picture_default.png'
  end

  factory :fullUser, class: User do
    first_name 'Maximus'
    last_name 'Mustermannnus'
    email 'maximus.mustermannus@example.com'
    password '12345678'
    gender 'Titan'
    profile_image_id 'profile_picture_default.png'
    about_me 'Sieh mich an und erstarre!'
  end
end
