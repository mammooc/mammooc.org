# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe CnmoocHouseCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'cnmooc.house') }

  let(:cnmooc_house_course_worker) { described_class.new }

  it 'delivers MOOCProvider' do
    expect(cnmooc_house_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'gets an API response' do
    pending
    expect(cnmooc_house_course_worker.course_data).not_to be_nil
  end
end
