require 'rails_helper'

describe OpenSAPCourseWorker do

  before(:all) do
    @moocProvider = FactoryGirl.create(:mooc_provider, name: 'openSAP')
  end

  let(:openSAPCourseWorker){
    OpenSAPCourseWorker.new
  }

  it 'should deliver MOOCProvider' do
    expect(openSAPCourseWorker.moocProvider).to eql @moocProvider
  end

  it 'should get an API response' do
    expect(openSAPCourseWorker.getCourseData).not_to be_nil
  end

end
