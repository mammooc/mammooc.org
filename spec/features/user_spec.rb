# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'User', type: :feature do
  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }
  let(:second_user) { FactoryGirl.create(:user) }
  let(:third_user) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }

  let!(:course_enrollments_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_enrollments_visibility, user: user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    end
  let!(:second_course_enrollments_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_enrollments_visibility, user: second_user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  context 'user' do
    before(:each) do
      UserGroup.set_is_admin(group.id, user.id, true)

      visit new_user_session_path
      fill_in 'login_email', with: user.primary_email
      fill_in 'login_password', with: user.password
      click_button 'submit_sign_in'

      ActionMailer::Base.deliveries.clear
    end

    describe 'show settings' do
      it 'navigate to account settings page', js: true do
        click_link "#{user.first_name} #{user.last_name}"
        click_link I18n.t('navbar.settings')
        wait_for_ajax
        uri = URI.parse(current_url)
        expect("#{uri.path}?#{uri.query}").to eq("#{user_settings_path(user.id)}?subsite=mooc_provider")
        expect(page).to have_content I18n.t('users.settings.mooc_provider_connection')
        click_button 'load-account-settings-button'
        wait_for_ajax
        uri = URI.parse(current_url)
        expect("#{uri.path}?#{uri.query}").to eq("#{user_settings_path(user.id)}?subsite=account")
        expect(page).to have_content I18n.t('users.settings.cancel_account')
      end

      it 'get error when trying to delete account but still admin in group', js: true do
        click_link "#{user.first_name} #{user.last_name}"
        click_link I18n.t('navbar.settings')
        click_button 'load-account-settings-button'
        if ENV['PHANTOM_JS'] == 'true'
          click_button I18n.t('users.settings.cancel_account')
        else
          accept_alert do
            click_button I18n.t('users.settings.cancel_account')
          end
        end
        wait_for_ajax
        expect(page).to have_content I18n.t('users.settings.still_admin_in_group_error')
      end
    end
  end

  context 'second user' do
    before(:each) do
      visit new_user_session_path
      fill_in 'login_email', with: second_user.primary_email
      fill_in 'login_password', with: second_user.password
      click_button 'submit_sign_in'

      ActionMailer::Base.deliveries.clear
    end

    describe 'show settings' do
      it 'deletes account successfully', js: true do
        click_link "#{second_user.first_name} #{second_user.last_name}"
        click_link I18n.t('navbar.settings')
        click_button 'load-account-settings-button'
        if ENV['PHANTOM_JS'] == 'true'
          click_button I18n.t('users.settings.cancel_account')
        else
          accept_alert do
            click_button I18n.t('users.settings.cancel_account')
          end
        end
        expect(page).to have_content I18n.t('devise.registrations.destroyed')
        expect { User.find(second_user.id) }.to raise_error
      end
    end
  end
end
