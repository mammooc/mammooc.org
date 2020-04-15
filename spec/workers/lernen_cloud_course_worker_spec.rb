# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LernenCloudCourseWorker do
  let!(:mooc_provider) { FactoryBot.create(:mooc_provider, name: 'Lernen.cloud') }

  let(:lernen_cloud_course_worker) { described_class.new }

  it 'delivers MOOCProvider' do
    expect(lernen_cloud_course_worker.mooc_provider).to eq mooc_provider
  end

  it 'gets an API response' do
    expect(lernen_cloud_course_worker.course_data).not_to be_nil
  end
end
