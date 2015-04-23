require 'rails_helper'

RSpec.describe OpenSAPUserWorker do

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    Sidekiq::Testing.inline!
  end

  it 'should load all users when no argument is passed' do
    expect_any_instance_of(OpenSAPConnector).to receive(:load_user_data).with(nil)
    OpenSAPUserWorker.perform_async
  end

  it 'should load specified user when the corresponding id is passed' do
    expect_any_instance_of(OpenSAPConnector).to receive(:load_user_data).with([user])
    OpenSAPUserWorker.perform_async([user.id])
  end

end
