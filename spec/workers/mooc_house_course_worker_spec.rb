# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MoocHouseCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'mooc.house') }

  let(:mooc_house_course_worker) { described_class.new }

  it 'delivers MOOCProvider' do
    expect(mooc_house_course_worker.mooc_provider).to eq mooc_provider
  end

  it 'gets an API response' do
    expect(mooc_house_course_worker.course_data).not_to be_nil
  end
end
