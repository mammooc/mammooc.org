# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConnectorMapper do
  include described_class

  let(:mooc_provider) { FactoryBot.create(:mooc_provider) }

  it 'returns no connector for unknown mooc_provider' do
    expect(get_connector_by_mooc_provider(mooc_provider)).to eq nil
  end

  it 'returns correspondent connector for known mooc_provider' do
    mooc_provider.name = 'openHPI'
    expect(get_connector_by_mooc_provider(mooc_provider).class).to eq OpenHPIConnector
    mooc_provider.name = 'openSAP'
    expect(get_connector_by_mooc_provider(mooc_provider).class).to eq OpenSAPConnector
    mooc_provider.name = 'mooc.house'
    expect(get_connector_by_mooc_provider(mooc_provider).class).to eq MoocHouseConnector
    mooc_provider.name = 'OpenWHO'
    expect(get_connector_by_mooc_provider(mooc_provider).class).to eq OpenWHOConnector
    mooc_provider.name = 'Lernen.cloud'
    expect(get_connector_by_mooc_provider(mooc_provider).class).to eq LernenCloudConnector
    # mooc_provider.name = 'coursera'
    # expect(get_connector_by_mooc_provider(mooc_provider).class).to eq CourseraConnector
  end

  it 'returns no worker for unknown mooc_provider' do
    expect(get_worker_by_mooc_provider(mooc_provider)).to eq nil
  end

  it 'returns correspondent worker for known mooc_provider' do
    mooc_provider.name = 'openHPI'
    expect(get_worker_by_mooc_provider(mooc_provider)).to eq OpenHPIUserWorker
    mooc_provider.name = 'openSAP'
    expect(get_worker_by_mooc_provider(mooc_provider)).to eq OpenSAPUserWorker
    mooc_provider.name = 'mooc.house'
    expect(get_worker_by_mooc_provider(mooc_provider)).to eq MoocHouseUserWorker
    mooc_provider.name = 'OpenWHO'
    expect(get_worker_by_mooc_provider(mooc_provider)).to eq OpenWHOUserWorker
    mooc_provider.name = 'Lernen.cloud'
    expect(get_worker_by_mooc_provider(mooc_provider)).to eq LernenCloudUserWorker
    # mooc_provider.name = 'coursera'
    # expect(get_worker_by_mooc_provider(mooc_provider)).to eq CourseraUserWorker
  end
end
