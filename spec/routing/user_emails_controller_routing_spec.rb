# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe UserEmailsController, type: :routing do
  describe 'routing' do

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
