# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Course', type: :feature do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do |example|
    unless example.metadata[:skip_before]
      visit new_user_session_path
      fill_in 'login_email', with: user.primary_email
      fill_in 'login_password', with: user.password
      click_button 'submit_sign_in'
    end

    ActionMailer::Base.deliveries.clear
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
      wait_for_ajax
      expect(page).to have_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
      wait_for_ajax
      click_link('recommend-course-link')
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
    end

    it 'displays only the rating view upon click', js: true do
      visit "/courses/#{course.id}"
      click_link('rate-course-link')
      wait_for_ajax
      expect(page).to have_selector('#rate-course')
      expect(page).to have_no_selector('#recommend-course')
      wait_for_ajax
      click_link('rate-course-link')
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
    end

    it 'toggles between rating and recommendations view upon click', js: true do
      visit "/courses/#{course.id}"
      click_link('rate-course-link')
      wait_for_ajax
      expect(page).to have_selector('#rate-course')
      expect(page).to have_no_selector('#recommend-course')
      wait_for_ajax
      click_link('recommend-course-link')
      expect(page).to have_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
      wait_for_ajax
      click_link('rate-course-link')
      expect(page).to have_selector('#rate-course')
      expect(page).to have_no_selector('#recommend-course')
      wait_for_ajax
      click_link('rate-course-link')
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
    end

    it 'toggles the enrollment button upon click', js: true do
      allow_any_instance_of(OpenHPIConnector).to receive(:enroll_user_for_course).and_return(true)
      visit course_path(course)
      expect(page).to have_no_selector('.unenroll-icon')
      expect(page).to have_selector('.enroll-icon')
      click_link('enroll-link')
      wait_for_ajax
      expect(page).to have_no_selector('.enroll-icon')
      expect(page).to have_selector('.unenroll-icon')
    end

    it 'toggles the unenrollment button upon click', js: true do
      user.courses << course
      allow_any_instance_of(OpenHPIConnector).to receive(:unenroll_user_for_course).and_return(true)
      visit "/courses/#{course.id}"
      expect(page).to have_no_selector('.enroll-icon')
      expect(page).to have_selector('.unenroll-icon')
      click_link('unenroll-link')
      wait_for_ajax
      expect(page).to have_no_selector('.unenroll-icon')
      expect(page).to have_selector('.enroll-icon')
    end
  end

  describe 'display the option to collapse long course descriptions' do
    let(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openSAP') }
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

    let(:second_user) { FactoryGirl.create(:user) }
    let!(:bookmark1) { FactoryGirl.create(:bookmark, user: user, course: course) }
    let!(:bookmark2) { FactoryGirl.create(:bookmark, user: user, course: right_course) }
    let!(:bookmark3) { FactoryGirl.create(:bookmark, user: user, course: course_free) }
    let!(:bookmark4) { FactoryGirl.create(:bookmark, user: second_user, course: course) }

    it 'filters courses for all filter criteria', js: true do
      visit courses_path
      expect(page).to have_content course.name
      fill_in 'new_search', with: 'nice name'
      fill_in 'filterrific_with_start_date_gte', with: Time.zone.today.strftime('%d.%m.%Y')
      fill_in 'filterrific_with_end_date_lte', with: (Time.zone.today + 3.weeks).strftime('%d.%m.%Y')
      select I18n.t('language.en'), from: 'filterrific_with_language'
      select open_hpi.name, from: 'filterrific_with_mooc_provider_id'
      select I18n.t('language.en'), from: 'filterrific_with_subtitle_languages'
      select I18n.t('courses.filter.duration.short'), from: 'filterrific_duration_filter_options'
      select I18n.t('courses.filter.start.now'), from: 'filterrific_start_filter_options'
      select I18n.t('courses.filter.costs.free'), from: 'filterrific_with_tracks_costs'
      select nice_track_type.title, from: 'filterrific_with_tracks_certificate'
      select I18n.t('courses.filter.sort.name_asc'), from: 'new_sort'
      check 'filterrific_bookmarked'
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
      expect(page.body.index(course.name)).to be < page.body.index(right_course.name)
    end
  end

  describe 'search for courses from navbar' do
    let!(:first_matching_course) { FactoryGirl.create(:course, name: 'Web Technologies') }
    let!(:second_matching_course) { FactoryGirl.create(:course, name: 'Webmaster') }
    let!(:not_matching_course) { FactoryGirl.create(:course, name: 'Ruby course') }

    it 'redirects to courses overview' do
      fill_in 'query', with: 'web'
      click_button 'submit-course-search-navbar'
      expect(current_path).to eq courses_path
    end

    it 'to find courses that match search query on courses overview' do
      fill_in 'query', with: 'web'
      click_button 'submit-course-search-navbar'
      expect(page).to have_content(first_matching_course.name)
      expect(page).to have_content(second_matching_course.name)
      expect(page).not_to have_content(not_matching_course.name)
    end

    it 'works if user is not signed in', skip_before: true do
      visit home_index_path
      fill_in 'query', with: 'web'
      click_button 'submit-course-search-navbar'
      expect(page).to have_content(first_matching_course.name)
      expect(page).to have_content(second_matching_course.name)
      expect(page).not_to have_content(not_matching_course.name)
    end
  end

  describe 'evaluate courses' do
    let(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI') }
    let!(:course) { FactoryGirl.create(:full_course, mooc_provider: mooc_provider) }

    it 'submit an evaluation and show a special form afterwards', js: true do
      visit "/courses/#{course.id}"
      click_link 'rate-course-link'
      wait_for_ajax
      expect(page).not_to have_content(I18n.t('evaluations.already_evaluated', first_name: user.first_name))
      find("div[class='user-rate-course-value']").first('span').all("div[class='rating-symbol']").last.click
      fill_in 'rating-textarea', with: 'Great Course!'
      find("label[id='option_aborted']").click
      click_button('submit-rating-button')
      wait_for_ajax
      expect(page).to have_content(I18n.t('evaluations.already_evaluated', first_name: user.first_name))
    end

    it 'show errors when submitting form with errors', js: true do
      visit "/courses/#{course.id}"
      click_link 'rate-course-link'
      fill_in 'rating-textarea', with: 'Great Course!'
      click_button('submit-rating-button')
      wait_for_ajax
      expect(page).to have_content(I18n.t('evaluations.state_overall_rating'))
      expect(page).to have_content(I18n.t('evaluations.state_course_status'))
      find("div[class='user-rate-course-value']").first('span').all("div[class='rating-symbol']").last.click
      find("label[id='option_aborted']").click
      click_button('submit-rating-button')
      wait_for_ajax
      expect(page).not_to have_content(I18n.t('evaluations.state_overall_rating'))
      expect(page).not_to have_content(I18n.t('evaluations.state_course_status'))
    end

    it 'shows my already submitted evaluation in _ratings', js: true do
      eval = FactoryGirl.create(:full_evaluation, user_id: user.id, course_id: course.id, course_status: :enrolled, rating: 4, description: 'blub')
      visit "/courses/#{course.id}"
      expect(page).to have_selector("div[class='course-rating']")
      expect(page).to have_content("(#{course.evaluations.count})")
      expect(page).to have_content("#{user.first_name} #{user.last_name} #{I18n.t('evaluations.currently_enrolled_course')}")
      expect(page).to have_content(eval.description)
    end

    it 'update evaluation', js: true do
      eval = FactoryGirl.create(:full_evaluation, user_id: user.id, course_id: course.id, course_status: :enrolled, rating: 4, description: 'blub')
      visit "/courses/#{course.id}"
      click_link 'rate-course-link'
      click_button 'edit-rating-button'
      wait_for_ajax
      expect(page.find("div[class='user-rate-course-value']").all("span[class='glyphicon glyphicon-star']").count).to eq(eval.rating)
      expect(page.find("textarea[id='rating-textarea']")).to have_content(eval.description)
      expect(page.find("label[class='btn btn-default active']")['data-value']).to eq(eval.course_status.to_s)
      find("div[class='user-rate-course-value']").first('span').all("div[class='rating-symbol']").last.click
      fill_in 'rating-textarea', with: 'Great Course!'
      find("label[id='option_aborted']").click
      click_button('submit-rating-button')
      wait_for_ajax
      expect(page).to have_content(I18n.t('evaluations.already_evaluated', first_name: user.first_name))
    end

    it 'mark an evaluation as helpful', js: true do
      eval1 = FactoryGirl.create(:minimal_evaluation, course_id: course.id, course_status: :enrolled, rating: 4, description: 'blub')
      visit "/courses/#{course.id}"
      find("a[id='rate-evaluation-link-0-true']").click
      wait_for_ajax
      expect(page.find("div[id='course-evaluations']")).to have_content(I18n.t('evaluations.thanks_for_feedback'))
      visit "/courses/#{course.id}"
      eval1.reload
      expect(page.find("div[id='course-evaluations']")).to have_content(I18n.t('evaluations.users_found_evaluation_helpful', positive_feedback_count: eval1.positive_feedback_count, feedback_count: eval1.total_feedback_count))
    end

    it 'mark an evaluation as not helpful', js: true do
      eval1 = FactoryGirl.create(:minimal_evaluation, course_id: course.id, course_status: :enrolled, rating: 4, description: 'blub')
      visit "/courses/#{course.id}"
      find("a[id='rate-evaluation-link-0-false']").click
      wait_for_ajax
      expect(page.find("div[id='course-evaluations']")).to have_content(I18n.t('evaluations.thanks_for_feedback'))
      visit "/courses/#{course.id}"
      eval1.reload
      expect(page.find("div[id='course-evaluations']")).to have_content(I18n.t('evaluations.users_found_evaluation_helpful', positive_feedback_count: eval1.positive_feedback_count, feedback_count: eval1.total_feedback_count))
    end

    it 'shows different rating form when not logged in', skip_before: true, js: true do
      visit "/courses/#{course.id}"
      click_link 'rate-course-link'
      expect(page).to have_content(I18n.t('evaluations.please_sign_in'))
      expect(page).to have_content(I18n.t('evaluations.path_to_registration'))
    end
  end
end
