# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe AbstractCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider) }
  let!(:course_list) { FactoryGirl.create_list(:full_course, 10, mooc_provider_id: mooc_provider.id) }

  let(:abstract_course_worker) { described_class.new }

  it 'creates a valid update_map' do
    update_map = abstract_course_worker.create_update_map mooc_provider
    expect(update_map.length).to eql 10
    update_map.each do |_, updated|
      expect(updated).to be false
    end
  end

  it 'evaluates the update_map and delete the right courses' do
    course_count = Course.count
    update_map = abstract_course_worker.create_update_map mooc_provider

    # set five courses to true
    update_map.each_with_index do |(course, _), index|
      update_map[course] = true
      index >= 4 ? break : next
    end

    abstract_course_worker.evaluate_update_map update_map
    expect(course_count).to eql Course.count + 5
  end

  it 'throws exceptions when trying to call abstract methods' do
    expect { abstract_course_worker.mooc_provider }.to raise_error NotImplementedError
    expect { abstract_course_worker.course_data }.to raise_error NotImplementedError
    expect { abstract_course_worker.handle_response_data 'test' }.to raise_error NotImplementedError
  end

  it 'handles internet connection error' do
    allow(abstract_course_worker).to receive(:course_data).and_raise SocketError
    expect { abstract_course_worker.load_courses }.not_to raise_error
  end

  it 'handles API not found error' do
    allow(abstract_course_worker).to receive(:course_data).and_raise RestClient::ResourceNotFound
    expect { abstract_course_worker.load_courses }.not_to raise_error
  end
end
