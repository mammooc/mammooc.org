require 'rails_helper'

describe OpenSAPCourseWorker do

  before(:all) do
    @mooc_provider = FactoryGirl.create(:mooc_provider, name: 'openSAP')
  end

  let(:open_sap_course_worker){
    OpenSAPCourseWorker.new
  }

  it 'should deliver MOOCProvider' do
    expect(open_sap_course_worker.mooc_provider).to eql @mooc_provider
  end

  it 'should get an API response' do
    expect(open_sap_course_worker.get_course_data).not_to be_nil
  end

end
