FactoryGirl.define do

  factory :group do
    name 'Gruppe1'
    description 'blabla'
    users {[FactoryGirl.create(:user, email: 'max@test.com')]}
  end

end