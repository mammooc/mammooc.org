# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe CoursesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/courses').to route_to('courses#index')
    end

    it 'routes to #show' do
      expect(get: '/courses/1').to route_to('courses#show', id: '1')
    end

    it 'routes to #enroll_course' do
      expect(get: '/courses/1/enroll_course').to route_to('courses#enroll_course', id: '1')
    end

    it 'routes to #unenroll_course' do
      expect(get: '/courses/1/unenroll_course').to route_to('courses#unenroll_course', id: '1')
    end

    it 'routes to #send_evaluation' do
      expect(post: '/courses/1/send_evaluation').to route_to('courses#send_evaluation', id: '1')
    end
  end
end
