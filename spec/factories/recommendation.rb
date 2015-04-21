FactoryGirl.define do

  factory :recommendation do
    is_obligatory false
    author {FactoryGirl.create(:user)}
    course {FactoryGirl.create(:course)}
    text  'Great Course!'
    users {[FactoryGirl.create(:user), FactoryGirl.create(:user)]}
    groups {[FactoryGirl.create(:group), FactoryGirl.create(:group)]}
  end

end
