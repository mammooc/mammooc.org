# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Registration', type: :feature do
  let(:user) { FactoryBot.build_stubbed(:user) }

  before do
    visit new_user_registration_path
    ActionMailer::Base.deliveries.clear
  end

  context 'with English' do
    it 'works with valid input' do
      fill_in 'user_full_name', with: user.full_name
      fill_in 'registration_email', with: user.primary_email
      fill_in 'registration_password', with: user.password
      fill_in 'registration_password_confirmation', with: user.password
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('devise.registrations.signed_up'))
      expect(User.find_by_primary_email(user.primary_email)).not_to be_nil # rubocop:disable Rails/DynamicFindBy
    end

    it 'does not work if email already taken' do
      existing_user = FactoryBot.create(:user)
      fill_in 'user_full_name', with: existing_user.full_name
      fill_in 'registration_email', with: existing_user.primary_email
      fill_in 'registration_password', with: existing_user.password
      fill_in 'registration_password_confirmation', with: existing_user.password
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('devise.registrations.email.taken'))
    end

    it 'does not work with a password that is too short' do
      fill_in 'user_full_name', with: user.full_name
      fill_in 'registration_email', with: user.primary_email
      fill_in 'registration_password', with: '123'
      fill_in 'registration_password_confirmation', with: '123'
      click_button 'submit_sign_up'
      expect(page).to have_text("#{I18n.t('users.sign_in_up.password')} #{I18n.t('flash.error.user.password_too_short', count: '8')}")
    end

    it 'does not work with two different password inputs' do
      fill_in 'user_full_name', with: user.full_name
      fill_in 'registration_email', with: user.primary_email
      fill_in 'registration_password', with: user.password
      fill_in 'registration_password_confirmation', with: '123456789'
      click_button 'submit_sign_up'
      expect(page).to have_text("#{I18n.t('users.sign_in_up.password_confirmation')} #{I18n.t('flash.error.user.password_confirmation')}")
    end

    it 'does not work without full_name' do
      fill_in 'registration_email', with: user.primary_email
      fill_in 'registration_password', with: user.password
      fill_in 'registration_password_confirmation', with: user.password
      click_button 'submit_sign_up'
      expect(page).to have_text("#{I18n.t('users.sign_in_up.full_name')} #{I18n.t('flash.error.blank')}")
    end

    it 'does not work if email is invalid' do
      fill_in 'user_full_name', with: user.full_name
      fill_in 'registration_email', with: 'invalidemail'
      fill_in 'registration_password', with: user.password
      fill_in 'registration_password_confirmation', with: user.password
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('devise.registrations.email.invalid'))
    end
  end

  context 'with German' do
    before do
      if page.text.match?(/EN/)
        click_on 'language_selection'
        click_on 'Deutsch'
      end
    end

    after do
      if page.text.match?(/DE/)
        click_on 'language_selection'
        click_on 'English'
      end
    end

    it 'works with valid input' do
      fill_in 'user_full_name', with: user.full_name
      fill_in 'registration_email', with: user.primary_email
      fill_in 'registration_password', with: user.password
      fill_in 'registration_password_confirmation', with: user.password
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('devise.registrations.signed_up'))
      expect(User.find_by_primary_email(user.primary_email)).not_to be_nil # rubocop:disable Rails/DynamicFindBy
    end

    it 'does not work if email already taken' do
      existing_user = FactoryBot.create(:user)
      fill_in 'user_full_name', with: existing_user.full_name
      fill_in 'registration_email', with: existing_user.primary_email
      fill_in 'registration_password', with: existing_user.password
      fill_in 'registration_password_confirmation', with: existing_user.password
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('devise.registrations.email.taken'))
    end

    it 'does not work with a password that is too short' do
      fill_in 'user_full_name', with: user.full_name
      fill_in 'registration_email', with: user.primary_email
      fill_in 'registration_password', with: '123'
      fill_in 'registration_password_confirmation', with: '123'
      click_button 'submit_sign_up'
      expect(page).to have_text("#{I18n.t('users.sign_in_up.password')} #{I18n.t('flash.error.user.password_too_short', count: '8')}")
    end

    it 'does not work with two different password inputs' do
      fill_in 'user_full_name', with: user.full_name
      fill_in 'registration_email', with: user.primary_email
      fill_in 'registration_password', with: user.password
      fill_in 'registration_password_confirmation', with: '123456789'
      click_button 'submit_sign_up'
      expect(page).to have_text("#{I18n.t('users.sign_in_up.password_confirmation')} #{I18n.t('flash.error.user.password_confirmation')}")
    end

    it 'does not work without full_name' do
      fill_in 'registration_email', with: user.primary_email
      fill_in 'registration_password', with: user.password
      fill_in 'registration_password_confirmation', with: user.password
      click_button 'submit_sign_up'
      expect(page).to have_text("#{I18n.t('users.sign_in_up.full_name')} #{I18n.t('flash.error.blank')}")
    end

    it 'does not work if email is invalid' do
      fill_in 'user_full_name', with: user.full_name
      fill_in 'registration_email', with: 'invalidemail'
      fill_in 'registration_password', with: user.password
      fill_in 'registration_password_confirmation', with: user.password
      click_button 'submit_sign_up'
      expect(page).to have_text(I18n.t('devise.registrations.email.invalid'))
    end
  end
end
