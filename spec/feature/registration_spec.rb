require 'rails_helper'

RSpec.describe Users::RegistrationsController, :type => :feature do

    let(:user) { FactoryGirl.build_stubbed(:user) }

    before(:each) do
      visit new_user_registration_path
    end

    it 'should work with valid input' do
      fill_in 'user_first_name', with: user.first_name
      fill_in 'user_last_name', with: user.last_name
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      fill_in 'user_password_confirmation', with: user.password
      check 'terms_and_conditions_confirmation'
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('devise.registrations.signed_up'))
      expect(User.find_by_email(user.email)).to_not be_nil
    end

    it 'should not work if email already taken' do
      FactoryGirl.create(:user)
      fill_in 'user_first_name', with: user.first_name
      fill_in 'user_last_name', with: user.last_name
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      fill_in 'user_password_confirmation', with: user.password
      check 'terms_and_conditions_confirmation'
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('email') + ' ' + I18n.t('activerecord.errors.messages.taken'))
    end

    it 'should not work if not agreed to terms and conditions' do
      fill_in 'user_first_name', with: user.first_name
      fill_in 'user_last_name', with: user.last_name
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      fill_in 'user_password_confirmation', with: user.password
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('terms_and_conditions_failure'))
    end

    it 'should not work with a password that is too short' do
      fill_in 'user_first_name', with: user.first_name
      fill_in 'user_last_name', with: user.last_name
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: '123'
      fill_in 'user_password_confirmation', with: '123'
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('password') + ' ' + I18n.t('activerecord.errors.models.user.attributes.password.too_short', count: '8'))
    end

    it 'should not work with two different password inputs' do
      fill_in 'user_first_name', with: user.first_name
      fill_in 'user_last_name', with: user.last_name
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      fill_in 'user_password_confirmation', with: '123456789'
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('password_confirmation') + ' ' + I18n.t('activerecord.errors.models.user.attributes.password_confirmation.confirmation'))
    end

    it 'should not work without first_name' do
      fill_in 'user_last_name', with: user.last_name
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      fill_in 'user_password_confirmation', with: user.password
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('first_name') + ' ' + I18n.t('activerecord.errors.messages.blank'))
    end
end