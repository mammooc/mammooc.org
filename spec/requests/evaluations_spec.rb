# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'Evaluations', type: :request do
  before(:each) do
    sign_in_as_a_valid_user
  end

  describe 'GET /evaluations' do
    it 'works! (now write some real specs)' do
      get evaluations_path
      expect(response).to have_http_status(200)
    end
  end
end
