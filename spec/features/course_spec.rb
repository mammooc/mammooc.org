require 'rails_helper'

RSpec.describe CoursesController, :type => :feature do

  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }
  let(:course) { FactoryGirl.create(:course)}

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


  describe 'display details of an existing course' do
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
end
