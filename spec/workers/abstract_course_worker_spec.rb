require 'rails_helper'
require 'sidekiq/testing'

describe AbstractCourseWorker do

  before(:all) do
    @moocProvider = FactoryGirl.create(:mooc_provider)
    FactoryGirl.create_list(:full_course, 10, mooc_provider_id: @moocProvider.id)
  end

  let (:abstractCourseWorker) {
    AbstractCourseWorker.new
  }

  it 'should create a valid updateMap' do
    updateMap = abstractCourseWorker.createUpdateMap @moocProvider
    expect(updateMap.length).to eql 10
    updateMap.each { |_, updated|
      expect(updated).to be false
    }
  end

  it 'should evaluate the updateMap and delete the right courses' do
    courseCount = Course.all.length
    updateMap = abstractCourseWorker.createUpdateMap @moocProvider
    # set five courses to true
    i = 0
    updateMap.each { |course,_|
      updateMap[course] = true
      i += 1
      i >= 5 ? break : next
    }
    abstractCourseWorker.evaluateUpdateMap updateMap
    expect(courseCount).to eql Course.all.length+5
  end

  it 'should throw exceptions when trying to call abstract methods' do
    expect{abstractCourseWorker.moocProvider}.to raise_error NotImplementedError
    expect{abstractCourseWorker.getCourseData}.to raise_error NotImplementedError
    expect{abstractCourseWorker.handleResponseData 'test'}.to raise_error NotImplementedError
  end

  it 'should handle internet connection error' do
    allow(abstractCourseWorker).to receive(:getCourseData).and_raise SocketError
    expect{abstractCourseWorker.loadCourses}.not_to raise_error
  end

  it 'should handle API not found error' do
    allow(abstractCourseWorker).to receive(:getCourseData).and_raise RestClient::ResourceNotFound
    expect{abstractCourseWorker.loadCourses}.not_to raise_error
  end

end
