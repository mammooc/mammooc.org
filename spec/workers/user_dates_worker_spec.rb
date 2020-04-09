# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDatesWorker do
  let(:user) { FactoryBot.create(:user) }

  before do
    Sidekiq::Testing.inline!
  end

  it 'loads dates for openHPI and openSAP' do
    expect_any_instance_of(OpenHPIConnector).to receive(:load_dates_for_users)
    expect_any_instance_of(OpenSAPConnector).to receive(:load_dates_for_users)
    expect_any_instance_of(MoocHouseConnector).to receive(:load_dates_for_users)
    expect_any_instance_of(OpenWHOConnector).to receive(:load_dates_for_users)
    expect_any_instance_of(LernenCloudConnector).to receive(:load_dates_for_users)
    described_class.perform_async
  end
end
