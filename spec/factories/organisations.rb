# encoding: utf-8
# frozen_string_literal: true

FactoryGirl.define do
  factory :organisation do
    sequence(:name) {|n| "Test University #{n}" }
    url 'https://example.com'
  end
end
