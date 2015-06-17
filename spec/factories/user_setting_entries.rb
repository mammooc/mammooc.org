FactoryGirl.define do
  factory :user_setting_entry do
    sequence(:key) {|n| "my_key_#{n}" }
    sequence(:value) {|n| "my_value_#{n}" }
    association :setting, factory: :user_setting
  end
end
