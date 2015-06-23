# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe EvaluationsController, type: :routing do
  describe 'routing' do
    it 'routes to #process_evaluation_rating' do
      expect(post: '/evaluations/1/process_evaluation_rating').to route_to('evaluations#process_evaluation_rating', id: '1')
    end
  end
end
