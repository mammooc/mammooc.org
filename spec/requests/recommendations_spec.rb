# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Recommendations', type: :request do
  before(:each) do
    sign_in_as_a_valid_user
  end

  describe 'GET /recommendations' do
    it 'works! (now write some real specs)' do
      get recommendations_path
      expect(response).to have_http_status(200)
    end
  end
end
