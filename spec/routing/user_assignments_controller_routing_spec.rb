# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe UserAssignmentsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/user_assignments').to route_to('user_assignments#index')
    end

    it 'routes to #new' do
      expect(get: '/user_assignments/new').to route_to('user_assignments#new')
    end

    it 'routes to #show' do
      expect(get: '/user_assignments/1').to route_to('user_assignments#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/user_assignments/1/edit').to route_to('user_assignments#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/user_assignments').to route_to('user_assignments#create')
    end

    it 'routes to #update' do
      expect(put: '/user_assignments/1').to route_to('user_assignments#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/user_assignments/1').to route_to('user_assignments#destroy', id: '1')
    end
  end
end
