# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe UserDatesWorker do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    Sidekiq::Testing.inline!
  end

  it 'loads dates for openHPI and openSAP' do
    expect_any_instance_of(OpenHPIConnector).to receive(:load_dates_for_users)
    expect_any_instance_of(OpenSAPConnector).to receive(:load_dates_for_users)
    expect_any_instance_of(MoocHouseConnector).to receive(:load_dates_for_users)
    expect_any_instance_of(CnmoocHouseConnector).to receive(:load_dates_for_users)
    expect_any_instance_of(OpenHPIChinaConnector).to receive(:load_dates_for_users)
    expect_any_instance_of(OpenSAPChinaConnector).to receive(:load_dates_for_users)
    expect_any_instance_of(OpenUNEConnector).to receive(:load_dates_for_users)
    described_class.perform_async
  end
end
