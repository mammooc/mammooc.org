FactoryGirl.define do
  factory :user_date do
    user { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
    mooc_provider { FactoryGirl.create(:mooc_provider) }
    date Time.now + 1.day
    title 'An event for testing purpose'
    kind 'submission'
    relevant true
    ressource_id_from_provider nil
  end

end
