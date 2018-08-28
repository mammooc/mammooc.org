# frozen_string_literal: true

FactoryBot.define do
  factory :user_date do
    user { FactoryBot.create(:user) }
    course { FactoryBot.create(:course) }
    date { Time.zone.now + 1.day }
    title { 'An event for testing purpose' }
    kind { 'submission' }
    relevant { true }
    ressource_id_from_provider { nil }
  end
end
