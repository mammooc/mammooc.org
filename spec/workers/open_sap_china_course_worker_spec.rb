# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OpenSAPChinaCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openSAP China') }

  let(:open_sap_china_course_worker) { described_class.new }

  it 'delivers MOOCProvider' do
    expect(open_sap_china_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'gets an API response' do
    expect(open_sap_china_course_worker.course_data).not_to be_nil
  end
end
