# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LernenCloudConnector do
  let!(:mooc_provider) { FactoryBot.create(:mooc_provider, name: 'Lernen.cloud', api_support_state: 'naive') }
  let!(:user) { FactoryBot.create(:user) }

  let(:lernen_cloud_connector) { described_class.new }

  it 'delivers MOOCProvider' do
    expect(lernen_cloud_connector.send(:mooc_provider)).to eq mooc_provider
  end

  it 'gets an API response' do
    connection = MoocProviderUser.new
    connection.access_token = '1234567890abcdef'
    connection.user_id = user.id
    connection.mooc_provider_id = mooc_provider.id
    connection.save
    expect { lernen_cloud_connector.send(:get_enrollments_for_user, user) }.to raise_error RestClient::Unauthorized
  end
end
