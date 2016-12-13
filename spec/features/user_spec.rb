# frozen_string_literal: true
require 'rails_helper'
require 'support/feature_support'

RSpec.describe 'User', type: :feature do
  let!(:user) { User.create!(first_name: 'Max', last_name: 'Mustermann', password: '12345678') }
  let!(:first_email) { FactoryGirl.create(:user_email, user: user) }
  let!(:second_user) { FactoryGirl.create(:user) }
  let(:third_user) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group, users: [user, second_user, third_user], name: 'Test Group') }

  let!(:course_enrollments_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_enrollments_visibility, user: user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end
  let!(:course_results_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_results_visibility, user: user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end
  let!(:course_progress_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_progress_visibility, user: user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end
  let!(:profile_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :profile_visibility, user: user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end
  let!(:second_course_enrollments_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_enrollments_visibility, user: second_user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end

  let!(:second_course_results_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_results_visibility, user: second_user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end
  let!(:second_course_progress_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_progress_visibility, user: second_user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end
  let!(:second_profile_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :profile_visibility, user: second_user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end

  context 'user' do
    before do
      UserGroup.set_is_admin(group.id, user.id, true)

      visit new_user_session_path
      fill_in 'login_email', with: user.primary_email
      fill_in 'login_password', with: user.password
      click_button 'submit_sign_in'

      ActionMailer::Base.deliveries.clear
    end

    describe 'show settings' do
      it 'navigates to all sub pages', js: true do
        click_link "#{user.first_name} #{user.last_name}"
        click_link I18n.t('navbar.settings')
        wait_for_ajax

        # MOOC provider settings
        uri = URI.parse(current_url)
        expect("#{uri.path}?#{uri.query}").to eq("#{user_settings_path(user.id)}?subsite=mooc_provider")
        expect(page).to have_content I18n.t('users.settings.mooc_provider_connection')

        # Account settings
        click_button 'load-account-settings-button'
        wait_for_ajax
        uri = URI.parse(current_url)
        expect("#{uri.path}?#{uri.query}").to eq("#{user_settings_path(user.id)}?subsite=account")
        expect(page).to have_content I18n.t('users.settings.cancel_account')

        # Privacy settings
        click_button 'load-privacy-settings-button'
        wait_for_ajax
        uri = URI.parse(current_url)
        expect("#{uri.path}?#{uri.query}").to eq("#{user_settings_path(user.id)}?subsite=privacy")
        expect(page).to have_content I18n.t('users.settings.privacy.title')

        # Newsletter settings
        click_button 'load-newsletter-settings-button'
        wait_for_ajax
        uri = URI.parse(current_url)
        expect("#{uri.path}?#{uri.query}").to eq("#{user_settings_path(user.id)}?subsite=newsletter")
        expect(page).to have_content I18n.t('users.settings.newsletter.title')
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

      it 'renders 3 partial when navigating to account settings page', js: true do
        visit "#{user_settings_path(user.id)}?subsite=mooc_provider"
        click_button 'load-account-settings-button'
        wait_for_ajax
        expect(page).to have_content I18n.t('activerecord.attributes.user.first_name')
        expect(page).to have_content I18n.t('activerecord.attributes.user.profile_image')
        expect(page).to have_content I18n.t('users.settings.change_emails.address')
        expect(page).to have_content I18n.t('users.settings.change_emails.primary')
        expect(page).to have_content I18n.t('users.settings.new_password')
        expect(page).to have_content I18n.t('users.settings.manage_omniauth')
        expect(page).to have_content I18n.t('users.settings.cancel_account')
      end
    end

    describe 'subsite account settings' do
      describe 'change email settings' do
        let!(:second_email) { FactoryGirl.create(:user_email, user: user, is_primary: false) }

        before do
          visit "#{user_settings_path(user.id)}?subsite=account"
        end

        it 'shows email addresses of user in expected order' do
          expect(user.emails.count).to eq 2
          expect(page.body.index(user.primary_email)).to be < page.body.index(second_email.address)
        end

        it 'change address of already existing email' do
          fill_in "user_user_email_address_#{second_email.id}", with: 'NewEmailAddress@example.com'
          click_button 'submit_change_email'
          expect(UserEmail.find(second_email.id).address).to eq 'NewEmailAddress@example.com'
        end

        it 'changes existing primary email' do
          expect(UserEmail.find(second_email.id).is_primary).to be false
          choose "user_user_email_is_primary_#{second_email.id}"
          click_button 'submit_change_email'
          expect(UserEmail.find(second_email.id).is_primary).to be true
          expect(UserEmail.find(first_email.id).is_primary).to be false
        end

        it 'change address of already existing email and makes it primary' do
          expect(UserEmail.find(second_email.id).is_primary).to be false
          fill_in "user_user_email_address_#{second_email.id}", with: 'NewEmailAddress@example.com'
          choose "user_user_email_is_primary_#{second_email.id}"
          click_button 'submit_change_email'
          expect(UserEmail.find(second_email.id).address).to eq 'NewEmailAddress@example.com'
          expect(UserEmail.find(second_email.id).is_primary).to be true
          expect(UserEmail.find(first_email.id).is_primary).to be false
        end

        context 'adding new emails' do
          it 'adds new field', js: true do
            expect(page).to have_css('table#table_for_user_emails tr', count: 4)
            click_button 'add_new_email_field'
            expect(page).to have_css('table#table_for_user_emails tr', count: 5)
          end

          it 'assigns right id to new field', js: true do
            click_button 'add_new_email_field'
            expect(page).to have_selector '#user_user_email_address_3'
          end

          it 'adds new radio button for new field', js: true do
            click_button 'add_new_email_field'
            expect(page).to have_selector '#user_user_email_is_primary_3'
          end

          it 'adds a remove row button for new field', js: true do
            click_button 'add_new_email_field'
            expect(page).to have_selector '#remove_button_3'
            expect(page).to have_selector '.remove_added_email_field'
          end

          it 'updates hidden count of email addresses', js: true do
            click_button 'add_new_email_field'
            expect(find('#user_index', visible: false).value).to eq '3'
          end

          it 'adds new email to user', js: true do
            click_button 'add_new_email_field'
            fill_in 'user_user_email_address_3', with: 'NewEmail@example.com'
            click_button 'submit_change_email'
            expect(UserEmail.where(user: user).count).to eq 3
            expect(UserEmail.find_by(address: 'NewEmail@example.com').is_primary).to be false
          end

          it 'adds new email and makes it primary', js: true do
            click_button 'add_new_email_field'
            fill_in 'user_user_email_address_3', with: 'NewEmail@example.com'
            choose 'user_user_email_is_primary_3'
            click_button 'submit_change_email'
            expect(UserEmail.where(user: user).count).to eq 3
            expect(UserEmail.find_by(address: 'NewEmail@example.com').is_primary).to be true
          end
        end

        context 'deleting emails' do
          it 'shows remove button only for not-primary addresses' do
            page.assert_selector('.remove_email', count: 1)
          end

          it 'deletes existing address when clicking on button', js: true do
            find('.remove_email').click
            wait_for_ajax
            click_button 'submit_change_email'
            expect(UserEmail.where(user: user).count).to eq 1
          end

          it 'deletes existing address when clicking on glyphicon', js: true do
            find('.glyphicon-remove').click
            wait_for_ajax
            click_button 'submit_change_email'
            expect(UserEmail.where(user: user).count).to eq 1
            expect(UserEmail.where(address: second_email.address)).to be_empty
          end

          it 'can not delete existing email if primary is selected', js: true do
            choose "user_user_email_is_primary_#{second_email.id}"
            find('.remove_email').click
            unless ENV['PHANTOM_JS'] == 'true'
              expect(page.driver.browser.switch_to.alert.text).to eq I18n.t('users.settings.change_emails.alert_can_not_delete_primary')
              page.driver.browser.switch_to.alert.accept
            end
            expect(UserEmail.where(user: user).count).to eq 2
            expect(page).to have_selector("#user_user_email_address_#{second_email.id}")
          end

          context 'adds new row and delete afterwards' do
            it 'is added and deleted from table', js: true do
              expect(page).to have_css('table#table_for_user_emails tr', count: 4)
              click_button 'add_new_email_field'
              expect(page).to have_selector '#user_user_email_address_3'
              click_button 'remove_button_3'
              wait_for_ajax
              expect(page).not_to have_selector '#user_user_email_address_3'
              expect(page).to have_css('table#table_for_user_emails tr', count: 4)
            end

            it 'has no influence on controller method', js: true do
              all_emails = UserEmail.all
              click_button 'add_new_email_field'
              click_button 'remove_button_3'
              wait_for_ajax
              click_button 'submit_change_email'
              expect(UserEmail.all).to eq all_emails
            end
          end

          context 'adds new rows and delete one afterwards' do
            it 'new rows are added to table and deleted row is deleted from table', js: true do
              4.times { click_button 'add_new_email_field' }
              click_button 'remove_button_5'
              wait_for_ajax
              expect(page).to have_selector '#user_user_email_address_3'
              expect(page).to have_selector '#user_user_email_address_4'
              expect(page).to have_selector '#user_user_email_address_6'
              expect(page).not_to have_selector '#user_user_email_address_5'
            end

            it 'adds the new email addresses, but ignore deleted', js: true do
              count = UserEmail.where(user: user).count
              4.times { click_button 'add_new_email_field' }
              click_button 'remove_button_5'
              wait_for_ajax
              fill_in 'user_user_email_address_3', with: 'new.email3@example.com'
              fill_in 'user_user_email_address_4', with: 'new.email4@example.com'
              fill_in 'user_user_email_address_6', with: 'new.email6@example.com'
              click_button 'submit_change_email'
              expect(UserEmail.where(user: user).count).to eq count + 3
            end
          end

          it 'can not delete new row with primary selected', js: true do
            click_button 'add_new_email_field'
            fill_in 'user_user_email_address_3', with: 'max.deleted@example.com'
            choose 'user_user_email_is_primary_3'
            click_button 'remove_button_3'
            unless ENV['PHANTOM_JS'] == 'true'
              expect(page.driver.browser.switch_to.alert.text).to eq I18n.t('users.settings.change_emails.alert_can_not_delete_primary')
              page.driver.browser.switch_to.alert.accept
            end
            expect(page).to have_selector '#user_user_email_address_3'
          end
        end

        it 'could update existing, create new, change primary and delete', js: true do
          third_email = FactoryGirl.create(:user_email, is_primary: false, user: user)
          visit "#{user_settings_path(user.id)}?subsite=account"
          fill_in "user_user_email_address_#{second_email.id}", with: 'NewEmailAddress@example.com'
          choose "user_user_email_is_primary_#{second_email.id}"
          find("#row_user_email_address_#{third_email.id}").find('.remove_email').click
          wait_for_ajax
          click_button 'add_new_email_field'
          wait_for_ajax
          fill_in 'user_user_email_address_4', with: 'max.muster@example.com'
          click_button 'add_new_email_field'
          click_button 'remove_button_5'
          click_button 'submit_change_email'
          expect(UserEmail.where(user: user).count).to eq 3
          expect(UserEmail.where(id: third_email.id)).to be_empty
          expect(UserEmail.where(address: 'max.muster@example.com').length).to eq 1
          expect(UserEmail.find(second_email.id).address).to eq 'NewEmailAddress@example.com'
          expect(UserEmail.find(second_email.id).is_primary).to be true
          expect(UserEmail.find(first_email.id).is_primary).to be false
        end

        it 'cancels action', js: true do
          third_email = FactoryGirl.create(:user_email, is_primary: false, user: user)
          visit "#{user_settings_path(user.id)}?subsite=account"
          fill_in "user_user_email_address_#{second_email.id}", with: 'NewEmailAddress@example.com'
          choose "user_user_email_is_primary_#{second_email.id}"
          find("#row_user_email_address_#{third_email.id}").find('.remove_email').click
          wait_for_ajax
          click_button 'add_new_email_field'
          wait_for_ajax
          fill_in 'user_user_email_address_4', with: 'max.muster@example.com'
          click_button 'add_new_email_field'
          click_button 'remove_button_5'
          click_on 'cancel_change_email'
          wait_for_ajax
          expect(UserEmail.where(user: user).count).to eq 3
          expect(UserEmail.where(id: third_email.id).length).to eq 1
          expect(UserEmail.find_by(address: 'max.muster@example.com')).to be_nil
          expect(UserEmail.find(second_email.id).address).to eq second_email.address
          expect(UserEmail.find(second_email.id).is_primary).to be false
          expect(UserEmail.find(first_email.id).is_primary).to be true
        end
      end
    end

    describe 'privacy settings' do
      # login and go to privacy settings page
      before do
        visit "#{user_settings_path(user.id)}?subsite=privacy"
        wait_for_ajax
      end

      describe 'course enrollments' do
        let(:list_id) { 'course-enrollments-visibility-groups-list' }
        let(:list) { find("##{list_id}", visible: false) }

        context 'groups' do
          it 'adds a group', js: true do
            find("button[data-list-id='#{list_id}']").click
            if ENV['PHANTOM_JS'] == 'true'
              name_input = find('#new-groups-name')
              name_input.click
              name_input.native.send_keys 'Test'
              wait_for_ajax
              name_input.native.send_key(:Enter)
            else
              fill_in 'new-groups-name', with: 'Test'
              wait_for_ajax
              fill_in 'new-groups-name', with: "\t"
            end
            list.find('.new-item-ok').click
            wait_for_ajax
            expect(list).to have_content(group.name)
            expect(course_enrollments_visibility_settings.value(:groups)).to eq [group.id]
          end
        end
      end
    end

    describe 'newsletter settings' do
      # login and go to newsletter settings page
      before do
        visit "#{user_settings_path(user.id)}?subsite=newsletter"
        wait_for_ajax
      end

      it 'sets newsletter_interval to 7 days', js: true do
        select I18n.t('users.settings.newsletter.interval.week'), from: 'user_newsletter_interval'
        click_button I18n.t('global.save')
        expect(User.find(user.id).newsletter_interval).to eq 7
        expect(User.find(user.id).unsubscribed_newsletter).to eq false
      end

      it 'unsubscribes newsletter for user', js: true do
        user.newsletter_interval = 7
        user.save
        select I18n.t('users.settings.newsletter.receive_no'), from: 'user_newsletter_interval'
        click_button I18n.t('global.save')
        expect(User.find(user.id).newsletter_interval).to be_nil
        expect(User.find(user.id).unsubscribed_newsletter).to eq true
      end
    end

    describe 'flash notice for newsletter' do
      context 'for users who are signed in ' do
        it 'is shown to user who has not subscribed or unsubscribed for newsletter' do
          user.unsubscribed_newsletter = nil
          user.save
          visit courses_index_path
          expect(page).to have_content I18n.t('newsletter.flash_notice')
        end

        it 'is not shown to user who has unsubscribed for newsletter' do
          user.unsubscribed_newsletter = true
          user.save
          visit courses_index_path
          expect(page).not_to have_content I18n.t('newsletter.flash_notice')
        end

        it 'is not shown to user who has subscribed for newsletter' do
          user.unsubscribed_newsletter = false
          user.save
          visit courses_index_path
          expect(page).not_to have_content I18n.t('newsletter.flash_notice')
        end

        it 'unsubscribes from newsletter' do
          visit courses_index_path
          click_on I18n.t('global.no_thanks')
          expect(User.find(user.id).unsubscribed_newsletter).to eq true
        end

        it 'stays on the same page' do
          visit courses_index_path
          click_on I18n.t('global.no_thanks')
          expect(page).to have_content I18n.t('courses.heading')
        end

        it 'redirects user to newsletter settings page' do
          visit courses_index_path
          click_on I18n.t('newsletter.subscribe')
          expect(page).to have_content I18n.t('users.settings.newsletter.title')
        end
      end

      context 'for users who are not signed in' do
        before do
          capybara_sign_out user
        end

        it 'is always shown' do
          visit courses_index_path
          expect(page).to have_content I18n.t('newsletter.flash_notice')
        end

        it 'signs in new user and redirects to newsletter settings' do
          visit courses_index_path
          click_on I18n.t('newsletter.subscribe')
          expect(page).to have_content I18n.t('users.sign_in_up.sign_in_process')
          fill_in 'login_email', with: user.primary_email
          fill_in 'login_password', with: user.password
          click_button 'submit_sign_in'
          expect(page).to have_content I18n.t('users.settings.newsletter.title')
        end
      end
    end
  end

  context 'second user' do
    before do
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
        expect { User.find(second_user.id) }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'deletes account successfully although the user has recommendations', js: true do
        FactoryGirl.create(:user_recommendation, author: second_user)
        FactoryGirl.create(:user_recommendation, users: [second_user])
        expect(Recommendation.count).to eq 2
        visit "#{user_settings_path(second_user.id)}?subsite=account"
        if ENV['PHANTOM_JS'] == 'true'
          click_button I18n.t('users.settings.cancel_account')
        else
          accept_alert do
            click_button I18n.t('users.settings.cancel_account')
          end
        end
        expect(page).to have_content I18n.t('devise.registrations.destroyed')
        expect { User.find(second_user.id) }.to raise_error ActiveRecord::RecordNotFound
        expect(Recommendation.count).to eq 0
      end

      it 'deletes account and removes recommendations where user is author', js: true do
        FactoryGirl.create(:group_recommendation, author: second_user)
        FactoryGirl.create(:user_recommendation, author: second_user)
        FactoryGirl.create(:user_recommendation)
        expect(Recommendation.count).to eq 3
        visit "#{user_settings_path(second_user.id)}?subsite=account"
        if ENV['PHANTOM_JS'] == 'true'
          click_button I18n.t('users.settings.cancel_account')
        else
          accept_alert do
            click_button I18n.t('users.settings.cancel_account')
          end
        end
        expect(page).to have_content I18n.t('devise.registrations.destroyed')
        expect { User.find(second_user.id) }.to raise_error ActiveRecord::RecordNotFound
        expect(Recommendation.count).to eq 1
      end

      it 'deletes account and removes user from his recommendations', js: true do
        FactoryGirl.create(:group_recommendation, users: [second_user, user])
        FactoryGirl.create(:user_recommendation, users: [second_user])
        FactoryGirl.create(:user_recommendation)
        expect(Recommendation.count).to eq 3
        visit "#{user_settings_path(second_user.id)}?subsite=account"
        if ENV['PHANTOM_JS'] == 'true'
          click_button I18n.t('users.settings.cancel_account')
        else
          accept_alert do
            click_button I18n.t('users.settings.cancel_account')
          end
        end
        expect(page).to have_content I18n.t('devise.registrations.destroyed')
        expect { User.find(second_user.id) }.to raise_error ActiveRecord::RecordNotFound
        expect(Recommendation.count).to eq 2
      end

      it 'deletes user account although user is owner of activity', js: true do
        FactoryGirl.create(:activity_bookmark, owner_id: second_user.id)
        visit "#{user_settings_path(second_user.id)}?subsite=account"
        if ENV['PHANTOM_JS'] == 'true'
          click_button I18n.t('users.settings.cancel_account')
        else
          accept_alert do
            click_button I18n.t('users.settings.cancel_account')
          end
        end
        expect(page).to have_content I18n.t('devise.registrations.destroyed')
        expect { User.find(second_user.id) }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'deletes user account and all activities where user is owner', js: true do
        FactoryGirl.create(:activity_bookmark, owner_id: second_user.id)
        FactoryGirl.create(:activity_bookmark)
        expect(PublicActivity::Activity.count).to eq 2
        visit "#{user_settings_path(second_user.id)}?subsite=account"
        if ENV['PHANTOM_JS'] == 'true'
          click_button I18n.t('users.settings.cancel_account')
        else
          accept_alert do
            click_button I18n.t('users.settings.cancel_account')
          end
        end
        expect(page).to have_content I18n.t('devise.registrations.destroyed')
        expect { User.find(second_user.id) }.to raise_error ActiveRecord::RecordNotFound
        expect(PublicActivity::Activity.count).to eq 1
      end

      it 'deletes user account and delete user from activites', js: true do
        FactoryGirl.create(:activity_bookmark, user_ids: [second_user.id], group_ids: [])
        FactoryGirl.create(:activity_bookmark, user_ids: [user.id, second_user.id])

        expect(PublicActivity::Activity.count).to eq 2
        visit "#{user_settings_path(second_user.id)}?subsite=account"
        if ENV['PHANTOM_JS'] == 'true'
          click_button I18n.t('users.settings.cancel_account')
        else
          accept_alert do
            click_button I18n.t('users.settings.cancel_account')
          end
        end
        expect(page).to have_content I18n.t('devise.registrations.destroyed')
        expect { User.find(second_user.id) }.to raise_error ActiveRecord::RecordNotFound
        expect(PublicActivity::Activity.count).to eq 1
      end
    end
  end
end
