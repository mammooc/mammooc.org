# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :user do
    sequence(:first_name) {|n| "Max_#{n}" }
    last_name 'Mustermann'
    password '12345678'

    after(:create) do |user, evaluator|
      if evaluator.primary_email.nil?
        create(:user_email, user: user)
      else
        create(:user_email, user: user, address: evaluator.primary_email)
      end
    end
    after(:stub) do |user, evaluator|
      if evaluator.primary_email.nil?
        user.emails = [build_stubbed(:user_email, user: user)]
      else
        user.emails = [build_stubbed(:user_email, user: user, address: evaluator.primary_email)]
      end
      allow(user).to receive(:primary_email).and_return(user.emails.first.address)
    end
  end

  factory :fullUser, class: User do
    first_name 'Maximus'
    last_name 'Mustermannnus'
    password '12345678'
    gender 'Titan'
    about_me 'Sieh mich an und erstarre!'
    after(:create) do |user|
      create(:user_email, user: user)
    end
    after(:stub) do |user|
      user.emails = [build_stubbed(:user_email, user: user)]
      allow(user).to receive(:primary_email).and_return(user.emails.first.address)
    end
  end
end
