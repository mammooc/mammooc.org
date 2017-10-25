# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    sequence(:name) {|n| "Gruppe #{n}" }
    description 'Lorem ipsum Bacon Soda.'
    users { [FactoryBot.create(:user), FactoryBot.create(:user)] }
  end
end
