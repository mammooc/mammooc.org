require 'rails_helper'

RSpec.describe MoocHouseConnector do

  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'mooc.house') }
  let!(:user) { FactoryGirl.create(:user) }

  let(:mooc_house_connector){ MoocHouseConnector.new }

  it 'should deliver MOOCProvider' do
    expect(mooc_house_connector.send(:mooc_provider)).to eql mooc_provider
  end

  it 'should get an API response' do
    pending
    connection = MoocProviderUser.new
    connection.authentication_token = '1234567890abcdef'
    connection.user_id = user.id
    connection.mooc_provider_id = mooc_provider.id
    connection.save
    expect{mooc_house_connector.send(:get_enrollments_for_user, user)}.to raise_error RestClient::InternalServerError
  end
end
