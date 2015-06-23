# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe CompletionsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'users/1/completions').to route_to('completions#index', user_id: '1')
    end
  end
end
