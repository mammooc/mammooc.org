# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpenWHOCourseWorker do
  let!(:mooc_provider) { FactoryBot.create(:mooc_provider, name: 'OpenWHO') }

  let(:open_who_course_worker) { described_class.new }

  it 'delivers MOOCProvider' do
    expect(open_who_course_worker.mooc_provider).to eq mooc_provider
  end

  it 'gets an API response' do
    expect(open_who_course_worker.course_data).not_to be_nil
  end
end
