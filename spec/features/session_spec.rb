require 'rails_helper'

RSpec.describe Users::SessionsController, type: :feature do

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    visit new_user_session_path
  end

  it 'should work with valid input' do
    fill_in 'login_email', with: user.email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.sessions.signed_in'))
  end

  it 'should not work if password is wrong' do
    fill_in 'login_email', with: user.email
    fill_in 'login_password', with: 'wrongpassword'
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.failure.invalid', authentication_keys: 'email'))
  end

  it 'should not work if password is wrong' do
    fill_in 'login_email', with: 'wrongemail@example.com'
    fill_in 'login_password', with: 'wrongpassword'
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.failure.not_found_in_database', authentication_keys: 'email'))
  end

  it 'should logout if logout button clicked' do
    fill_in 'login_email', with: user.email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.sessions.signed_in'))
    click_link 'nav_sign_out_button'
    expect(page).to have_text(I18n.t('devise.sessions.signed_out'))
  end

  it 'should update course data after sucessful sign in' do
    expect(UserWorker).to receive(:perform_async).with([user.id])
    fill_in 'login_email', with: user.email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.sessions.signed_in'))
  end

  it 'should not update course data after unsuccessful login attempt' do
    expect(UserWorker).not_to receive(:perform_async).with([user.id])
    fill_in 'login_email', with: 'wrongemail@example.com'
    fill_in 'login_password', with: 'wrongpassword'
    click_button 'submit_sign_in'
    expect(page).to have_text(I18n.t('devise.failure.not_found_in_database', authentication_keys: 'email'))
  end
end