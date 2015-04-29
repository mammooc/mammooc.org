require 'rails_helper'

RSpec.describe "Application", type: :feature do

  describe 'GET any URL without being signed in' do

    let(:user) { FactoryGirl.create(:user) }

    it 'should redirect to sign in' do
      visit groups_path
      expect(current_path).to eq(new_user_session_path)
    end

    it 'should redirect to original URL after sign in' do
      visit groups_path
      fill_in 'login_email', with: user.email
      fill_in 'login_password', with: user.password
      click_button 'submit_sign_in'
      expect(current_path).to eq(groups_path)
    end

    it 'should redirect to original URL after sign up' do
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

    it 'should redirect to root after visiting sign in page' do
      visit new_user_session_path
      fill_in 'login_email', with: user.email
      fill_in 'login_password', with: user.password
      click_button 'submit_sign_in'
      expect(current_path).to eq(dashboard_path)
    end

    it 'should redirect to root after visiting sign up page' do
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
end