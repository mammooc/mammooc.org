# frozen_string_literal: true

FactoryGirl.define do
  factory :user_date do
    user { FactoryGirl.create(:user) }
    course { FactoryGirl.create(:course) }
    date { Time.zone.now + 1.day }
    title 'An event for testing purpose'
    kind 'submission'
    relevant true
    ressource_id_from_provider nil
  end
end
