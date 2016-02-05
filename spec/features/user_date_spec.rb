# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'
require 'support/feature_support'

RSpec.describe 'UserDate', type: :feature do
  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    Sidekiq::Testing.inline!

    capybara_sign_in(user)
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  describe 'index page' do
    it 'shows calendar widget', js: true do
      visit '/user_dates'
      expect(page).to have_selector('.calendar')
      expect(page).to have_content(Time.zone.today.strftime('%B'))
      expect(page).to have_selector('.fc-toolbar')
      expect(page).to have_selector('.fc-view-container')
    end

    it 'includes dates for shown month', js: true do
      user_date = FactoryGirl.create(:user_date, date: Time.zone.today, user: user)
      visit '/user_dates'
      expect(page).to have_content(user_date.title)
    end

    it 'refreshes calendar widget', js: true do
      visit '/user_dates'
      user_date = FactoryGirl.create(:user_date, date: Time.zone.today, user: user)
      expect(page).to have_no_content(user_date.title)
      click_button 'sync-user-dates'
      wait_for_ajax
      expect(page).to have_content(user_date.title)
    end
  end
end
