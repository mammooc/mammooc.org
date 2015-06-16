# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe CompletionsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/completions').to route_to('completions#index')
    end
  end
end
