# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarkWorker do
  let(:user) { FactoryBot.create(:user, primary_email: 'test@example.com') }

  before do
    Sidekiq::Testing.inline!
    ActionMailer::Base.deliveries.clear
  end

  describe 'send_reminder_for_bookmarked_courses' do
    let(:reminder_course) { FactoryBot.create(:course, start_date: Time.zone.today + 1.week) }
    let(:earlier_course) { FactoryBot.create(:course, start_date: Time.zone.today + 2.days) }
    let(:later_course) { FactoryBot.create(:course, start_date: Time.zone.today + 2.weeks) }
    let!(:reminder_bookmark) { FactoryBot.create(:bookmark, user: user, course: reminder_course) }
    let!(:reminder_bookmark2) { FactoryBot.create(:bookmark, user: user, course: reminder_course) }
    let!(:earlier_bookmark) { FactoryBot.create(:bookmark, user: user, course: earlier_course) }
    let!(:later_bookmark) { FactoryBot.create(:bookmark, user: user, course: later_course) }

    it 'sends reminder for a course that starts in exactly one week' do
      described_class.perform_async
      expect(ActionMailer::Base.deliveries.count).to eq 2
    end
  end
end
