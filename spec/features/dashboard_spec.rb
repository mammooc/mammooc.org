# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'Dashboard', type: :feature do
  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group, users: [user]) }
  let(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI') }
  let!(:course) { FactoryGirl.create(:full_course, mooc_provider: mooc_provider, provider_course_id: '12345') }
  let(:json_enrollment_data) do
    JSON.parse "[{\"id\":\"dfcfdf0f-e0ad-4887-abfa-83cc233c291f\",\"course_id\":\"12345\"}]"
  end
  before(:each) do
    Sidekiq::Testing.inline!

    visit new_user_session_path
    fill_in 'login_email', with: user.primary_email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  describe 'display enrolled courses' do
    it 'shows newly enrolled course after synchronization request', js: true do
      FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
      allow_any_instance_of(OpenHPIConnector).to receive(:get_enrollments_for_user).and_return(json_enrollment_data)

      visit '/dashboard'
      expect(page).to have_no_content(course.name)
      click_button 'sync-user-course-button'
      wait_for_ajax
      expect(page).to have_content(course.name)
    end

    it 'removes a currently enrolled course after synchronization request', js: true do
      FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: mooc_provider, access_token: '123')
      allow_any_instance_of(OpenHPIConnector).to receive(:get_enrollments_for_user).and_return(JSON.parse '{}')
      user.courses << course

      visit '/dashboard'
      expect(page).to have_content(course.name)
      click_button 'sync-user-course-button'
      wait_for_ajax
      expect(page).to have_no_content(course.name)
    end
  end
end
