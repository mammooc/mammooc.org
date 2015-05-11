# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'Users::Registration', type: :feature do
  self.use_transactional_fixtures = false
  let(:user) { FactoryGirl.build_stubbed(:user) }

  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  before(:each) do
    visit new_user_registration_path
  end

  it 'works with valid input' do
    fill_in 'user_first_name', with: user.first_name
    fill_in 'user_last_name', with: user.last_name
    fill_in 'registration_email', with: user.email
    fill_in 'registration_password', with: user.password
    fill_in 'registration_password_confirmation', with: user.password
    check 'terms_and_conditions_confirmation'
    click_button 'submit_sign_up'
    expect(page).to have_text(I18n.t('devise.registrations.signed_up'))
    expect(User.find_by_email(user.email)).to_not be_nil
  end

  it 'does not work if email already taken' do
    FactoryGirl.create(:user, email: user.email)
    fill_in 'user_first_name', with: user.first_name
    fill_in 'user_last_name', with: user.last_name
    fill_in 'registration_email', with: user.email
    fill_in 'registration_password', with: user.password
    fill_in 'registration_password_confirmation', with: user.password
    check 'terms_and_conditions_confirmation'
    click_button 'submit_sign_up'
    expect(page).to have_text(I18n.t('users.sign_in_up.email') + ' ' + I18n.t('flash.error.taken'))
  end

  it 'does not work if not agreed to terms and conditions' do
    fill_in 'user_first_name', with: user.first_name
    fill_in 'user_last_name', with: user.last_name
    fill_in 'registration_email', with: user.email
    fill_in 'registration_password', with: user.password
    fill_in 'registration_password_confirmation', with: user.password
    click_button 'submit_sign_up'
    expect(page).to have_text(I18n.t('flash.error.sign_up.terms_and_conditions_failure'))
  end

  it 'does not work with a password that is too short' do
    fill_in 'user_first_name', with: user.first_name
    fill_in 'user_last_name', with: user.last_name
    fill_in 'registration_email', with: user.email
    fill_in 'registration_password', with: '123'
    fill_in 'registration_password_confirmation', with: '123'
    click_button 'submit_sign_up'
    expect(page).to have_text(I18n.t('users.sign_in_up.password') + ' ' + I18n.t('flash.error.user.password_too_short', count: '8'))
  end

  it 'does not work with two different password inputs' do
    fill_in 'user_first_name', with: user.first_name
    fill_in 'user_last_name', with: user.last_name
    fill_in 'registration_email', with: user.email
    fill_in 'registration_password', with: user.password
    fill_in 'registration_password_confirmation', with: '123456789'
    click_button 'submit_sign_up'
    expect(page).to have_text(I18n.t('users.sign_in_up.password_confirmation') + ' ' + I18n.t('flash.error.user.password_confirmation'))
  end

  it 'does not work without first_name' do
    fill_in 'user_last_name', with: user.last_name
    fill_in 'registration_email', with: user.email
    fill_in 'registration_password', with: user.password
    fill_in 'registration_password_confirmation', with: user.password
    click_button 'submit_sign_up'
    expect(page).to have_text(I18n.t('users.sign_in_up.first_name') + ' ' + I18n.t('flash.error.blank'))
  end
end
