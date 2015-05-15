# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe UserEmailsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/user_emails').to route_to('user_emails#index')
    end

    it 'routes to #new' do
      expect(get: '/user_emails/new').to route_to('user_emails#new')
    end

    it 'routes to #show' do
      expect(get: '/user_emails/1').to route_to('user_emails#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/user_emails/1/edit').to route_to('user_emails#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/user_emails').to route_to('user_emails#create')
    end

    it 'routes to #update' do
      expect(put: '/user_emails/1').to route_to('user_emails#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/user_emails/1').to route_to('user_emails#destroy', id: '1')
    end
  end
end
