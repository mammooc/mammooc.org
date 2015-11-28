require 'rails_helper'

RSpec.describe UserDate, type: :model do
  let (:user) { FactoryGirl.create(:user) }

  describe 'synchronize user' do

    it 'should call openHPI and openSAP Connectors to load the dates for the given user' do
      expect_any_instance_of(OpenHPIConnector).to receive(:load_dates_for_users).with([user])
      expect_any_instance_of(OpenSAPConnector).to receive(:load_dates_for_users).with([user])
      described_class.synchronize(user)
    end

    it 'should set for each called Connector the synchronization_state to true' do
      expect_any_instance_of(OpenHPIConnector).to receive(:load_dates_for_users).with([user]).and_return(true)
      expect_any_instance_of(OpenSAPConnector).to receive(:load_dates_for_users).with([user]).and_return(true)
      synchronization_state = UserDate.synchronize(user)
      expect(synchronization_state[:openHPI]).to eql (true)
      expect(synchronization_state[:openSAP]).to eql (true)
    end

  end

  describe 'create current calendar for a given user' do

    let(:user_date) {FactoryGirl.create(:user_date, user: user)}

    context 'returns a calendar with an event representing the user_date' do
      it 'sets the start time correctly' do
        user_date
        calendar = described_class.create_current_calendar(user)
        expect(calendar.events.first.dtstart).to eql(user_date.date.to_date)
      end

      it 'sets the end time correctly' do
        user_date
        calendar = described_class.create_current_calendar(user)
        expect(calendar.events.first.dtend).to eql(user_date.date.to_date + 1.day)
      end

      it 'sets the summary correctly' do
        user_date
        calendar = described_class.create_current_calendar(user)
        expect(calendar.events.first.summary).to eql(user_date.title)
      end

      it 'sets the description correctly' do
        user_date
        calendar = described_class.create_current_calendar(user)
        expect(calendar.events.first.description).to include(user_date.kind)
        expect(calendar.events.first.description).to include(user_date.course.name)
      end
    end

    it 'collects more than one event' do
      5.times do
        FactoryGirl.create(:user_date, user: user)
      end
      calendar = described_class.create_current_calendar(user)
      expect(calendar.events.count).to eql(5)
    end

    it 'collects only the dates of the given user' do
      5.times do
        FactoryGirl.create(:user_date)
      end
      2.times do
        FactoryGirl.create(:user_date, user: user)
      end
      calendar = described_class.create_current_calendar(user)
      expect(calendar.events.count).to eql(2)
    end
  end

  describe 'generate token for a user' do

    let(:user) {FactoryGirl.create(:user)}

    it 'does not create a token if there is already one defined' do
      token = '1234567890'
      user.token_for_user_dates = token
      described_class.generate_token_for_user(user)
      expect(user.token_for_user_dates).to eql(token)
    end

    it 'saves a token to the database for the given user' do
      expect(user.token_for_user_dates).to be nil
      described_class.generate_token_for_user(user)
      expect(user.token_for_user_dates).not_to be nil
    end

    it 'creates a unique token for each user' do
      5.times do
        FactoryGirl.create(:user)
      end
      User.all.each do |user|
        described_class.generate_token_for_user(user)
      end
      created_tokens = User.all.collect(&:token_for_user_dates)
      expect(created_tokens.uniq.count).to eql(created_tokens.count)
    end
  end
end
