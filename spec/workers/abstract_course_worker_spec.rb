require 'rails_helper'
require 'sidekiq/testing'

describe AbstractCourseWorker do

  before(:all) do
    @mooc_provider = FactoryGirl.create(:mooc_provider)
    FactoryGirl.create_list(:full_course, 10, mooc_provider_id: @mooc_provider.id)
  end

  let (:abstract_course_worker) {
    AbstractCourseWorker.new
  }

  it 'should create a valid update_map' do
    update_map = abstract_course_worker.create_update_map @mooc_provider
    expect(update_map.length).to eql 10
    update_map.each { |_, updated|
      expect(updated).to be false
    }
  end

  it 'should evaluate the update_map and delete the right courses' do
    course_count = Course.count
    update_map = abstract_course_worker.create_update_map @mooc_provider

    # set five courses to true
    update_map.each_with_index { |(course,_),index|
      update_map[course] = true
      index >= 4 ? break : next
    }

    abstract_course_worker.evaluate_update_map update_map
    expect(course_count).to eql Course.count+5
  end

  it 'should throw exceptions when trying to call abstract methods' do
    expect{abstract_course_worker.mooc_provider}.to raise_error NotImplementedError
    expect{abstract_course_worker.get_course_data}.to raise_error NotImplementedError
    expect{abstract_course_worker.handle_response_data 'test'}.to raise_error NotImplementedError
  end

  it 'should handle internet connection error' do
    allow(abstract_course_worker).to receive(:get_course_data).and_raise SocketError
    expect{abstract_course_worker.load_courses}.not_to raise_error
  end

  it 'should handle API not found error' do
    allow(abstract_course_worker).to receive(:get_course_data).and_raise RestClient::ResourceNotFound
    expect{abstract_course_worker.load_courses}.not_to raise_error
  end

end
