require 'rails_helper'

RSpec.describe CoursesController, :type => :feature do

  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }
  let(:course) { FactoryGirl.create(:full_course)}

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
      expect(page).to have_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
      click_link('recommend-course-link')
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
    end

    it 'should only display the rating view upon click', js: true do
      visit "/courses/#{course.id}"
      click_link('rate-course-link')
      expect(page).to have_selector('#rate-course')
      expect(page).to have_no_selector('#recommend-course')
      click_link('rate-course-link')
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
    end

    it 'should toggle between rating and recommendations view upon click', js: true do
      visit "/courses/#{course.id}"
      click_link('rate-course-link')
      expect(page).to have_selector('#rate-course')
      expect(page).to have_no_selector('#recommend-course')
      click_link('recommend-course-link')
      expect(page).to have_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
      click_link('rate-course-link')
      expect(page).to have_selector('#rate-course')
      expect(page).to have_no_selector('#recommend-course')
      click_link('rate-course-link')
      expect(page).to have_no_selector('#recommend-course')
      expect(page).to have_no_selector('#rate-course')
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
