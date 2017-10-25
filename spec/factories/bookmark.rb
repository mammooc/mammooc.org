# frozen_string_literal: true

FactoryBot.define do
  factory :bookmark do
    user { FactoryBot.create(:user) }
    course { FactoryBot.create(:course) }
  end
end
