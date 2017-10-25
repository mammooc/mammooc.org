# frozen_string_literal: true

FactoryBot.define do
  factory :organisation do
    sequence(:name) {|n| "Test University #{n}" }
    url 'https://example.com'
  end
end
