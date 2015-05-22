# -*- encoding : utf-8 -*-
require 'rails_helper'
include ConnectorMapper

RSpec.describe ConnectorMapper do
  let(:mooc_provider) { FactoryGirl.create(:mooc_provider) }

  it 'returns no connector for unknown mooc_provider' do
    expect(get_connector_by_mooc_provider mooc_provider).to eql nil
  end

  it 'returns correspondent connector for known mooc_provider' do
    mooc_provider.name = 'openHPI'
    expect((get_connector_by_mooc_provider mooc_provider).class).to eql OpenHPIConnector
    mooc_provider.name = 'openSAP'
    expect((get_connector_by_mooc_provider mooc_provider).class).to eql OpenSAPConnector
    mooc_provider.name = 'openHPI China'
    expect((get_connector_by_mooc_provider mooc_provider).class).to eql OpenHPIChinaConnector
    mooc_provider.name = 'openSAP China'
    expect((get_connector_by_mooc_provider mooc_provider).class).to eql OpenSAPChinaConnector
    mooc_provider.name = 'mooc.house'
    expect((get_connector_by_mooc_provider mooc_provider).class).to eql MoocHouseConnector
    mooc_provider.name = 'openUNE'
    expect((get_connector_by_mooc_provider mooc_provider).class).to eql OpenUNEConnector
    mooc_provider.name = 'coursera'
    expect((get_connector_by_mooc_provider mooc_provider).class).to eql CourseraConnector
  end

  it 'returns no worker for unknown mooc_provider' do
    expect(get_worker_by_mooc_provider mooc_provider).to eql nil
  end

  it 'returns correspondent worker for known mooc_provider' do
    mooc_provider.name = 'openHPI'
    expect(get_worker_by_mooc_provider mooc_provider).to eql OpenHPIUserWorker
    mooc_provider.name = 'openSAP'
    expect(get_worker_by_mooc_provider mooc_provider).to eql OpenSAPUserWorker
    mooc_provider.name = 'openHPI China'
    expect(get_worker_by_mooc_provider mooc_provider).to eql OpenHPIChinaUserWorker
    mooc_provider.name = 'openSAP China'
    expect(get_worker_by_mooc_provider mooc_provider).to eql OpenSAPChinaUserWorker
    mooc_provider.name = 'mooc.house'
    expect(get_worker_by_mooc_provider mooc_provider).to eql MoocHouseUserWorker
    mooc_provider.name = 'openUNE'
    expect(get_worker_by_mooc_provider mooc_provider).to eql OpenUNEUserWorker
    mooc_provider.name = 'coursera'
    expect(get_worker_by_mooc_provider mooc_provider).to eql CourseraUserWorker
  end
end
