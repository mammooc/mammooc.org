# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserWorker do
  let(:user) { FactoryBot.create(:user) }

  before do
    Sidekiq::Testing.inline!
  end

  it 'loads all users when no argument is passed' do
    expect(OpenHPIUserWorker).to receive(:perform_async).with(nil)
    expect(OpenSAPUserWorker).to receive(:perform_async).with(nil)
    expect(OpenHPIChinaUserWorker).to receive(:perform_async).with(nil)
    expect(OpenWHOUserWorker).to receive(:perform_async).with(nil)
    expect(MoocHouseUserWorker).to receive(:perform_async).with(nil)
    expect(CourseraUserWorker).to receive(:perform_async).with(nil)
    described_class.perform_async
  end

  it 'loads specified user when the corresponding id is passed' do
    expect(OpenHPIUserWorker).to receive(:perform_async).with([user.id])
    expect(OpenSAPUserWorker).to receive(:perform_async).with([user.id])
    expect(OpenHPIChinaUserWorker).to receive(:perform_async).with([user.id])
    expect(OpenWHOUserWorker).to receive(:perform_async).with([user.id])
    expect(MoocHouseUserWorker).to receive(:perform_async).with([user.id])
    expect(CourseraUserWorker).to receive(:perform_async).with([user.id])
    described_class.perform_async [user.id]
  end
end
