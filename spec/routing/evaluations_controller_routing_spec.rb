# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EvaluationsController, type: :routing do
  describe 'routing' do
    it 'routes to #process_feedback' do
      expect(post: '/evaluations/1/process_feedback').to route_to('evaluations#process_feedback', id: '1')
    end
  end
end
