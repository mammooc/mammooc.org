FactoryGirl.define do

  factory :recommendation do
    is_obligatory false
    author {FactoryGirl.create(:user)}
    course {FactoryGirl.create(:course)}
    group {FactoryGirl.create(:group)}
    text  'Great Course!'
    users {[FactoryGirl.create(:user), FactoryGirl.create(:user)]}
  end

end
