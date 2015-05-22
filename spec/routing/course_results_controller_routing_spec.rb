# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe CourseResultsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/course_results').to route_to('course_results#index')
    end

    it 'routes to #new' do
      expect(get: '/course_results/new').to route_to('course_results#new')
    end

    it 'routes to #show' do
      expect(get: '/course_results/1').to route_to('course_results#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/course_results/1/edit').to route_to('course_results#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/course_results').to route_to('course_results#create')
    end

    it 'routes to #update' do
      expect(put: '/course_results/1').to route_to('course_results#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/course_results/1').to route_to('course_results#destroy', id: '1')
    end
  end
end
