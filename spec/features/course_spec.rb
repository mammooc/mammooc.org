require 'rails_helper'

RSpec.describe CoursesController, type: :feature do

  self.use_transactional_fixtures = false

  let(:mooc_provider){FactoryGirl.create(:mooc_provider, name:'openHPI')}
  let(:user) { FactoryGirl.create(:user) }
  let!(:course) { FactoryGirl.create(:full_course, mooc_provider: mooc_provider)}

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
    it 'should not display the collapsible items', js: true do
      visit "/courses/#{course.id}"
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
    end

    it 'should only display the recommendation view upon click', js: true do
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

    it 'should only display the rating view upon click', js: true do
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

    it 'should toggle between rating and recommendations view upon click', js: true do
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

    it 'should toggle the enrollment button upon click', js: true do
      allow_any_instance_of(OpenHPIConnector).to receive(:enroll_user_for_course).and_return(true)
      visit "/courses/#{course.id}"
      click_link('enroll-course-link')
      wait_for_ajax
      expect(page).to have_no_selector('#enroll-course-link')
      expect(page).to have_selector('#unenroll-course-link')
    end

    it 'should toggle the unenrollment button upon click', js: true do
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
    it 'should display a button', js: true do
      visit "/courses/#{course.id}"
      expect(page).to have_selector('#course-description')
      expect(page).to have_content I18n.t('global.show_more')
      find("a[id='course-description-show-more']").click
      expect(page).to have_content I18n.t('global.show_less')
    end
  end
  
end
