require 'rails_helper'

RSpec.describe OpenUNEUserWorker do

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    Sidekiq::Testing.inline!
  end

  it 'should load all users when no argument is passed' do
    expect_any_instance_of(OpenUNEConnector).to receive(:load_user_data).with(nil)
    OpenUNEUserWorker.perform_async
  end

  it 'should load specified user when the corresponding id is passed' do
    expect_any_instance_of(OpenUNEConnector).to receive(:load_user_data).with([user])
    OpenUNEUserWorker.perform_async([user.id])
  end

end
