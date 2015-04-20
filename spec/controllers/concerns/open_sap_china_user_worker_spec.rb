require 'rails_helper'

RSpec.describe OpenSAPChinaConnector do

  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openSAP China') }
  let!(:user) { FactoryGirl.create(:user) }

  let(:open_sap_china_connector){ OpenSAPChinaConnector.new }

  it 'should deliver MOOCProvider' do
    expect(open_sap_china_connector.send(:mooc_provider)).to eql mooc_provider
  end

  it 'should get an API response' do
    pending
    connection = MoocProviderUser.new
    connection.authentication_token = '1234567890abcdef'
    connection.user_id = user.id
    connection.mooc_provider_id = mooc_provider.id
    connection.save
    expect{open_sap_china_connector.send(:get_enrollments_for_user, user)}.to raise_error RestClient::InternalServerError
  end
end
