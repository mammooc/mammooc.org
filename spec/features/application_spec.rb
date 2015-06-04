# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'Application', type: :feature do
  self.use_transactional_fixtures = false

  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  describe 'GET any URL without being signed in' do
    let(:user) { FactoryGirl.create(:user) }

    it 'redirects to sign in' do
      visit groups_path
      expect(current_path).to eq(new_user_session_path)
    end

    it 'redirects to original URL after sign in' do
      visit groups_path
      fill_in 'login_email', with: user.primary_email
      fill_in 'login_password', with: user.password
      click_button 'submit_sign_in'
      expect(current_path).to eq(groups_path)
    end

    it 'redirects to original URL after sign up' do
      visit groups_path
      click_on 'Not signed up yet? Click here to sign up.'
      fill_in 'user_first_name', with: 'Maxi'
      fill_in 'user_last_name', with: 'Musterfrau'
      fill_in 'registration_email', with: 'maxi@example.com'
      fill_in 'registration_password', with: '12345678'
      fill_in 'registration_password_confirmation', with: '12345678'
      check 'terms_and_conditions_confirmation'
      click_button 'submit_sign_up'
      expect(current_path).to eq(groups_path)
    end

    it 'redirects to root after visiting sign in page' do
      visit new_user_session_path
      fill_in 'login_email', with: user.primary_email
      fill_in 'login_password', with: user.password
      click_button 'submit_sign_in'
      expect(current_path).to eq(dashboard_path)
    end

    it 'redirects to root after visiting sign up page' do
      visit new_user_registration_path
      fill_in 'user_first_name', with: 'Maxi'
      fill_in 'user_last_name', with: 'Musterfrau'
      fill_in 'registration_email', with: 'maxi@example.com'
      fill_in 'registration_password', with: '12345678'
      fill_in 'registration_password_confirmation', with: '12345678'
      check 'terms_and_conditions_confirmation'
      click_button 'submit_sign_up'
      expect(current_path).to eq(dashboard_path)
    end
  end

  describe 'log in via navbar' do
    let(:user) { FactoryGirl.create(:user) }

    it 'redirects to original URL after sign in' do
      visit courses_path
      click_on 'dropdown_for_login'
      fill_in 'user_primary_email', with: user.primary_email
      fill_in 'user_password', with: user.password
      click_on 'submit_sign_in_dropdown'
      expect(current_path).to eq courses_path
      expect(page).to have_content user.first_name
    end

  end

end
