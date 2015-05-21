# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'Course', type: :feature do
  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    visit new_user_session_path
    fill_in 'login_email', with: user.email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'

    ActionMailer::Base.deliveries.clear
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  describe 'display form to recommend or rate an existing course' do
    let(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI') }
    let!(:course) { FactoryGirl.create(:full_course, mooc_provider: mooc_provider) }

    it 'does not display the collapsible items', js: true do
      visit "/courses/#{course.id}"
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
    end

    it 'displays only the recommendation view upon click', js: true do
      visit "/courses/#{course.id}"
      click_link('recommend-course-link')
      wait_for_phantom_js
      expect(page).to have_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
      wait_for_phantom_js
      click_link('recommend-course-link')
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
    end

    it 'displays only the rating view upon click', js: true do
      visit "/courses/#{course.id}"
      click_link('rate-course-link')
      wait_for_phantom_js
      expect(page).to have_selector('#rate-course')
      expect(page).to have_no_selector('#recommend-course')
      wait_for_phantom_js
      click_link('rate-course-link')
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
    end

    it 'toggles between rating and recommendations view upon click', js: true do
      visit "/courses/#{course.id}"
      click_link('rate-course-link')
      wait_for_phantom_js
      expect(page).to have_selector('#rate-course')
      expect(page).to have_no_selector('#recommend-course')
      wait_for_phantom_js
      click_link('recommend-course-link')
      expect(page).to have_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
      wait_for_phantom_js
      click_link('rate-course-link')
      expect(page).to have_selector('#rate-course')
      expect(page).to have_no_selector('#recommend-course')
      wait_for_phantom_js
      click_link('rate-course-link')
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
    end

    it 'toggles the enrollment button upon click', js: true do
      allow_any_instance_of(OpenHPIConnector).to receive(:enroll_user_for_course).and_return(true)
      visit "/courses/#{course.id}"
      click_link('enroll-course-link')
      wait_for_ajax
      expect(page).to have_no_selector('#enroll-course-link')
      expect(page).to have_selector('#unenroll-course-link')
    end

    it 'toggles the unenrollment button upon click', js: true do
      user.courses << course
      allow_any_instance_of(OpenHPIConnector).to receive(:unenroll_user_for_course).and_return(true)
      visit "/courses/#{course.id}"
      click_link('unenroll-course-link')
      wait_for_ajax
      expect(page).to have_no_selector('#unenroll-course-link')
      expect(page).to have_selector('#enroll-course-link')
    end
  end

  describe 'display the option to collapse long course descriptions' do
    let(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI') }
    let!(:course) { FactoryGirl.create(:full_course, mooc_provider: mooc_provider) }

    it 'displays a button', js: true do
      visit "/courses/#{course.id}"
      expect(page).to have_selector('#course-description')
      expect(page).to have_content I18n.t('global.show_more')
      find("a[id='course-description-show-more']").click
      expect(page).to have_content I18n.t('global.show_less')
    end
  end

  describe 'filter course page' do
    let(:nice_track_type) { FactoryGirl.create(:course_track_type, title: 'Nice course track') }
    let(:wrong_track_type) { FactoryGirl.create(:course_track_type, title: 'Wrong course track') }

    let(:free_track) { FactoryGirl.create(:free_course_track, track_type: nice_track_type) }
    let(:expensive_track) { FactoryGirl.create(:course_track, costs: 60.0, track_type: wrong_track_type) }
    let(:expensive_certificate_track) { FactoryGirl.create(:certificate_course_track, costs: 50.0, track_type: nice_track_type) }
    let(:free_track_with_wrong_type) { FactoryGirl.create(:free_course_track, track_type: wrong_track_type) }
    let(:free_track_2) { FactoryGirl.create(:free_course_track, track_type: nice_track_type) }
    let(:free_track_3) { FactoryGirl.create(:free_course_track, track_type: nice_track_type) }
    let(:expensive_track_2) { FactoryGirl.create(:course_track, costs: 60.0, track_type: wrong_track_type) }
    let(:expensive_track_3) { FactoryGirl.create(:course_track, costs: 60.0, track_type: wrong_track_type) }

    let(:open_hpi) { FactoryGirl.create(:mooc_provider, name: 'openHPI') }
    let!(:course) { FactoryGirl.create(:course, name: 'Course that matches all criteria nice name', start_date: Time.zone.now, end_date: Time.zone.now + 2.weeks, language: 'en', mooc_provider: open_hpi, subtitle_languages: 'en', calculated_duration_in_days: 28, tracks: [free_track]) }
    let!(:course_starts_before) { FactoryGirl.create(:course, name: 'Course starts before', start_date: Time.zone.now - 2.weeks) }
    let!(:course_ends_after) { FactoryGirl.create(:course, name: 'Course ends after', end_date: Time.zone.now + 3.weeks) }
    let!(:course_german) { FactoryGirl.create(:course, name: 'Course german', language: 'de') }
    let(:open_sap) { FactoryGirl.create(:mooc_provider, name: 'openSAP') }
    let!(:course_open_sap) { FactoryGirl.create(:course, name: 'Course from openSAP', mooc_provider: open_sap) }
    let!(:course_german_subtitle) { FactoryGirl.create(:course, name: 'Course with german subtitles', subtitle_languages: 'de') }
    let!(:course_longer_duration) { FactoryGirl.create(:course, name: 'Course with longer duration', calculated_duration_in_days: 42) }
    let!(:course_expensive) { FactoryGirl.create(:course, name: 'Expensive Course', tracks: [expensive_track]) }
    let!(:course_expensive_certificate) { FactoryGirl.create(:course, name: 'Expensive Certificate Course', tracks: [expensive_certificate_track]) }
    let!(:course_free) { FactoryGirl.create(:course, name: 'Free but wrong Course', tracks: [free_track_with_wrong_type]) }
    let!(:right_course) { FactoryGirl.create(:course, name: 'Course that matches all criteria too nice name', start_date: Time.zone.now, end_date: Time.zone.now + 2.weeks, language: 'en', mooc_provider: open_hpi, subtitle_languages: 'en', calculated_duration_in_days: 28, tracks: [free_track_2]) }
    let!(:course_wrong_attributes_1) { FactoryGirl.create(:course, name: 'Course that does not match all criteria 1', start_date: Time.zone.now, end_date: Time.zone.now + 2.weeks, language: 'zh', mooc_provider: open_hpi, subtitle_languages: 'de', calculated_duration_in_days: 28, tracks: [free_track_3]) }
    let!(:course_wrong_attributes_2) { FactoryGirl.create(:course, name: 'Course that does not match all criteria 2', start_date: Time.zone.now - 1.day, end_date: Time.zone.now + 2.weeks, language: 'en', mooc_provider: open_sap, subtitle_languages: 'en', calculated_duration_in_days: 28, tracks: [expensive_track_2]) }
    let!(:course_wrong_attributes_3) { FactoryGirl.create(:course, name: 'Course that does not match all criteria 3', start_date: Time.zone.now, end_date: Time.zone.now + 2.weeks, language: 'en', mooc_provider: open_hpi, subtitle_languages: 'en', calculated_duration_in_days: 35, tracks: [expensive_track_3]) }

    it 'filters courses for all filter criteria', js: true do
      # TODO: delete after mobile optimization
      unless ENV['PHANTOM_JS'] == 'true'
        page.driver.browser.manage.window.resize_to(1024, 768)
      end
      visit courses_path
      expect(page).to have_content course.name
      fill_in 'filterrific_search_query', with: 'nice name'
      fill_in 'filterrific_with_start_date_gte', with: (Time.zone.today).strftime('%d.%m.%Y')
      fill_in 'filterrific_with_end_date_lte', with: (Time.zone.today + 3.weeks).strftime('%d.%m.%Y')
      select I18n.t('language.english'), from: 'filterrific_with_language'
      select open_hpi.name, from: 'filterrific_with_mooc_provider_id'
      select I18n.t('language.english'), from: 'filterrific_with_subtitle_languages'
      select I18n.t('courses.filter.duration.short'), from: 'filterrific_duration_filter_options'
      select I18n.t('courses.filter.start.now'), from: 'filterrific_start_filter_options'
      select I18n.t('courses.filter.costs.free'), from: 'filterrific_with_tracks_costs'
      select nice_track_type.title, from: 'filterrific_with_tracks_certificate'
      select I18n.t('courses.filter.sort.name_desc'), from: 'filterrific_sorted_by'
      wait_for_ajax
      expect(page).to have_content course.name
      expect(page).not_to have_content course_starts_before.name
      expect(page).not_to have_content course_ends_after.name
      expect(page).not_to have_content course_german.name
      expect(page).not_to have_content course_open_sap.name
      expect(page).not_to have_content course_german_subtitle.name
      expect(page).not_to have_content course_longer_duration.name
      expect(page).not_to have_content course_expensive.name
      expect(page).not_to have_content course_expensive_certificate.name
      expect(page).not_to have_content course_free.name
      expect(page).not_to have_content course_wrong_attributes_1.name
      expect(page).not_to have_content course_wrong_attributes_2.name
      expect(page).not_to have_content course_wrong_attributes_3.name
      expect(page).to have_content right_course.name
      expect(page.body.index(course.name)).to be > page.body.index(right_course.name)
    end
  end
end
