require 'rails_helper'

describe OpenSAPCourseWorker do

  before(:all) do
    @mooc_provider = FactoryGirl.create(:mooc_provider, name: 'openSAP')
  end

  let(:openSAPCourseWorker){
    OpenSAPCourseWorker.new
  }

  it 'should deliver MOOCProvider' do
    expect(openSAPCourseWorker.mooc_provider).to eql @mooc_provider
  end

  it 'should get an API response' do
    expect(openSAPCourseWorker.get_course_data).not_to be_nil
  end

end
