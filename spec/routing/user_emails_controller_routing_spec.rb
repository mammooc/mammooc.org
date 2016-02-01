# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserEmailsController, type: :routing do
  describe 'routing' do
    it 'routes to #mark_as_deleted' do
      expect(get 'user_emails/1/mark_as_deleted').to route_to('user_emails#mark_as_deleted', id: '1')
    end
  end
end
