# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :group do
    name 'Gruppe1'
    description 'Lorem ipsum Bacon Soda.'
    image_id 'group_picture_default.png'
    users { [FactoryGirl.create(:user), FactoryGirl.create(:user)] }
  end
end
