# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'MoocProviders', type: :request do
  before(:each) do
    sign_in_as_a_valid_user
  end

  describe 'GET /mooc_providers' do
    it 'works! (now write some real specs)' do
      get mooc_providers_path, as: :json
      expect(response).to have_http_status(200)
    end
  end
end
