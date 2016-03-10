# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Users::Session', type: :feature do
  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    visit new_user_session_path
    ActionMailer::Base.deliveries.clear
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  it 'works with valid input' do
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.sessions.signed_in'))
  end

  it 'does not work if password is wrong' do
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: 'wrongpassword'
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.failure.invalid', authentication_keys: 'email'))
  end

  it 'does not work if email is wrong' do
    fill_in 'login_email', with: 'wrongemail@example.com'
    fill_in 'login_password', with: 'wrongpassword'
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.failure.not_found_in_database', authentication_keys: 'email'))
  end

  it 'logouts if logout button clicked' do
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.sessions.signed_in'))
    click_link 'nav_sign_out_button'
    expect(page).to have_text(I18n.t('devise.sessions.signed_out'))
  end

  it 'updates course enrollments after sucessful sign in' do
    expect(UserWorker).to receive(:perform_async).with([user.id])
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.sessions.signed_in'))
  end

  it 'does not update course enrollments after unsuccessful login attempt' do
    expect(UserWorker).not_to receive(:perform_async).with([user.id])
    fill_in 'login_email', with: 'wrongemail@example.com'
    fill_in 'login_password', with: 'wrongpassword'
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.failure.not_found_in_database', authentication_keys: 'email'))
  end

  it 'shows finish sign up page if no primary email is provided (e.g. when using OmniAuth) and saves the input' do
    user = FactoryGirl.create(:OmniAuthUser)
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('users.sign_in_up.finish_sign_up'))
    fill_in 'primary_email_finish_sign_up', with: 'max@example.com'
    click_button 'submit_finish_sign_up'
    expect(user.primary_email).to eql 'max@example.com'
    expect(page).to have_text(I18n.t('flash.notice.users.successfully_updated'))
  end

  it 'shows finish sign up page if no first name is provided (e.g. when using OmniAuth) and saves the input' do
    user = FactoryGirl.create(:OmniAuthUser)
    identity = UserIdentity.find_by(user: user)
    user.first_name = "autogenerated@#{identity.provider_user_id}-#{identity.omniauth_provider}.com"
    user.primary_email = 'max@example.com'
    user.save!
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('users.sign_in_up.finish_sign_up'))
    fill_in 'first_name_finish_sign_up', with: 'Max'
    click_button 'submit_finish_sign_up'
    expect(user.reload.first_name).to eql 'Max'
    expect(page).to have_text(I18n.t('flash.notice.users.successfully_updated'))
  end

  it 'shows finish sign up page if no last name is provided (e.g. when using OmniAuth) and saves the input' do
    user = FactoryGirl.create(:OmniAuthUser)
    identity = UserIdentity.find_by(user: user)
    user.last_name = "autogenerated@#{identity.provider_user_id}-#{identity.omniauth_provider}.com"
    user.primary_email = 'max@example.com'
    user.save!
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('users.sign_in_up.finish_sign_up'))
    fill_in 'last_name_finish_sign_up', with: 'Musterfrau'
    click_button 'submit_finish_sign_up'
    expect(user.reload.last_name).to eql 'Musterfrau'
    expect(page).to have_text(I18n.t('flash.notice.users.successfully_updated'))
  end

  it 'shows finish sign up page when accessing another page' do
    user = FactoryGirl.create(:OmniAuthUser)
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('users.sign_in_up.finish_sign_up'))
    visit dashboard_path
    expect(page).to have_text(I18n.t('users.sign_in_up.finish_sign_up'))
  end
end
