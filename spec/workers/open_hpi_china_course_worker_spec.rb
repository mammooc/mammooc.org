# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe OpenHPIChinaCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI China') }

  let(:open_hpi_china_course_worker) { described_class.new }

  it 'delivers MOOCProvider' do
    expect(open_hpi_china_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'gets an API response' do
    pending
    expect(open_hpi_china_course_worker.course_data).not_to be_nil
  end
end
