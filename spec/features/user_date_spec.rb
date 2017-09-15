# frozen_string_literal: true

require 'rails_helper'
require 'support/feature_support'

RSpec.describe 'UserDate', type: :feature do
  let(:user) { FactoryGirl.create(:user) }

  before do
    Sidekiq::Testing.inline!

    capybara_sign_in(user)
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
      wait_for_ajax
      user_date = FactoryGirl.create(:user_date, date: Time.zone.today, user: user)
      expect(page).to have_no_content(user_date.title)
      click_button 'sync-user-dates'
      wait_for_ajax
      expect(page).to have_content(user_date.title)
    end
  end
end
