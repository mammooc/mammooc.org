require 'rails_helper'

describe OpenHPIChinaCourseWorker do

  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI China') }

  let(:open_hpi_china_course_worker){ OpenHPIChinaCourseWorker.new }

  it 'should deliver MOOCProvider' do
    expect(open_hpi_china_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'should get an API response' do
    pending
    expect(open_hpi_china_course_worker.get_course_data).not_to be_nil
  end

end
