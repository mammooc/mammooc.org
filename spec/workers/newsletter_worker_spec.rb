# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NewsletterWorker do
  let(:user) { FactoryGirl.create(:user, primary_email: 'test@example.com') }

  before(:each) do
    Sidekiq::Testing.inline!
    ActionMailer::Base.deliveries.clear
  end

  describe 'send_email_with_new_courses' do
    let(:another_user) { FactoryGirl.create(:user, primary_email: 'test123@example.com') }

    it 'sends email only if user has subscribed for newsletter' do
      FactoryGirl.create(:course)
      user.newsletter_interval = 5
      user.unsubscribed_newsletter = false
      user.save
      expect(another_user.unsubscribed_newsletter).to be_nil
      described_class.perform_async
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it 'does not send email if user has unsubscribed from newsletter' do
      FactoryGirl.create(:course)
      user.newsletter_interval = 5
      user.unsubscribed_newsletter = false
      user.save
      another_user.unsubscribed_newsletter = true
      another_user.save
      described_class.perform_async
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it 'sends email only if the defined newsletter_interval is reached again' do
      FactoryGirl.create(:course)
      user.newsletter_interval = 5
      user.unsubscribed_newsletter = false
      user.last_newsletter_send_at = Time.zone.today - 5.days
      user.save
      another_user.newsletter_interval = 5
      another_user.last_newsletter_send_at = Time.zone.today - 4.days
      another_user.save
      described_class.perform_async
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it 'sends email if the newsletter is send for the first time to the user' do
      FactoryGirl.create(:course)
      user.newsletter_interval = 5
      user.unsubscribed_newsletter = false
      user.last_newsletter_send_at = nil
      user.save
      described_class.perform_async
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it 'does not send email if there are no courses available' do
      user.newsletter_interval = 5
      user.unsubscribed_newsletter = false
      user.save
      described_class.perform_async
      expect(ActionMailer::Base.deliveries.count).to eq 0
    end

  end
end
