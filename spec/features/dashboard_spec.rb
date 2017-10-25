# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard', type: :feature do
  let(:user) { FactoryBot.create(:user) }

  before do
    Sidekiq::Testing.inline!

    visit new_user_session_path
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
  end

  describe 'display enrolled courses' do
    let(:group) { FactoryBot.create(:group, users: [user]) }
    let(:mooc_provider) { FactoryBot.create(:mooc_provider, name: 'openHPI') }
    let!(:course) { FactoryBot.create(:full_course, mooc_provider: mooc_provider, provider_course_id: '12345') }
    let(:json_enrollment_data) do
      JSON::Api::Vanilla.parse "{
    \"data\": [
        {
            \"type\": \"enrollments\",
            \"id\": \"d652d5d6-3624-4fb1-894f-2ea1c05bf5c4\",
            \"links\": {
                \"self\": \"/api/v2/enrollments/d652d5d6-3624-4fb1-894f-2ea1c05bf5c4\"
            },
            \"attributes\": {
                \"visits\": {
                    \"visited\": 12,
                    \"total\": 12,
                    \"percentage\": 100
                },
                \"points\": {
                    \"achieved\": 0,
                    \"maximal\": 0,
                    \"percentage\": null
                },
                \"certificates\": {
                    \"confirmation_of_participation\": true,
                    \"record_of_achievement\": null,
                    \"qualified_certificate\": null
                },
                \"completed\": false,
                \"reactivated\": false,
                \"proctored\": false,
                \"created_at\": \"2016-11-25T17:18:22.627Z\"
            },
            \"relationships\": {
                \"course\": {
                    \"data\": {
                        \"type\": \"courses\",
                        \"id\": \"12345\"
                    },
                    \"links\": {
                        \"related\": \"/api/v2/courses/12345\"
                    }
                },
                \"progress\": {
                    \"data\": {
                        \"type\": \"course-progresses\",
                        \"id\": \"12345\"
                    },
                    \"links\": {
                        \"related\": \"/api/v2/course-progresses/12345\"
                    }
                }
            }
        }
    ]
}"
    end

    it 'shows newly enrolled course after synchronization request', js: true do
      FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
      allow_any_instance_of(OpenHPIConnector).to receive(:get_enrollments_for_user).and_return(json_enrollment_data)

      visit '/dashboard'
      expect(page).to have_no_content(course.name)
      click_button 'sync-user-course-button'
      wait_for_ajax
      expect(page).to have_content(course.name)
    end

    it 'removes a currently enrolled course after synchronization request', js: true do
      FactoryBot.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
      allow_any_instance_of(OpenHPIConnector).to receive(:get_enrollments_for_user).and_return([])
      user.courses << course

      visit '/dashboard'
      expect(page).to have_content(course.name)
      click_button 'sync-user-course-button'
      wait_for_ajax
      expect(page).to have_no_content(course.name)
    end
  end

  describe 'current user dates' do
    let(:mooc_provider) { FactoryBot.create(:mooc_provider, name: 'openHPI') }

    it 'shows three current dates on dashboard' do
      date1 = Time.zone.today + 1.day
      date2 = Time.zone.today + 3.days
      date3 = Time.zone.today + 5.days
      FactoryBot.create(:user_date, date: date1, user: user)
      FactoryBot.create(:user_date, date: date2, user: user)
      FactoryBot.create(:user_date, date: date3, user: user)

      visit '/dashboard'
      expect(page).to have_content(date1.strftime(I18n.t('global.date_format_month_short')))
      expect(page).to have_content(date2.strftime(I18n.t('global.date_format_month_short')))
      expect(page).to have_content(date3.strftime(I18n.t('global.date_format_month_short')))
    end

    it 'refreshes dates', js: true do
      date1 = Time.zone.today + 1.day
      date2 = Time.zone.today + 3.days
      date3 = Time.zone.today + 5.days
      date4 = Time.zone.today + 4.days
      FactoryBot.create(:user_date, date: date1, user: user)
      FactoryBot.create(:user_date, date: date2, user: user)
      FactoryBot.create(:user_date, date: date3, user: user)

      visit '/dashboard'
      FactoryBot.create(:user_date, date: date4, user: user)
      expect(page).to have_content(date1.strftime(I18n.t('global.date_format_month_short')))
      expect(page).to have_content(date2.strftime(I18n.t('global.date_format_month_short')))
      expect(page).to have_content(date3.strftime(I18n.t('global.date_format_month_short')))
      expect(page).to have_no_content(date4.strftime(I18n.t('global.date_format_month_short')))
      click_button 'sync-user-dates-button'
      wait_for_ajax
      expect(page).to have_content(date1.strftime(I18n.t('global.date_format_month_short')))
      expect(page).to have_content(date2.strftime(I18n.t('global.date_format_month_short')))
      expect(page).to have_no_content(date3.strftime(I18n.t('global.date_format_month_short')))
      expect(page).to have_content(date4.strftime(I18n.t('global.date_format_month_short')))
    end
  end
end
