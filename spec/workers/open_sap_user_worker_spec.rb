# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OpenSAPUserWorker do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    Sidekiq::Testing.inline!
  end

  it 'loads all users when no argument is passed' do
    expect_any_instance_of(OpenSAPConnector).to receive(:load_user_data).with(no_args)
    described_class.perform_async
  end

  it 'loads specified user when the corresponding id is passed' do
    expect_any_instance_of(OpenSAPConnector).to receive(:load_user_data).with([user])
    described_class.perform_async([user.id])
  end
end
