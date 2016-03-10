# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/users/1').to route_to('users#show', id: '1')
    end

    it 'routes to #update' do
      expect(put: '/users/1').to route_to('users#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/users/1').to route_to('users#destroy', id: '1')
    end

    it 'routes to #completions' do
      expect(get: 'users/1/completions').to route_to('users#completions', id: '1')
    end
  end
end
