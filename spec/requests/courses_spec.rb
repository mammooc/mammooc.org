# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Courses', type: :request do
  before(:each) do
    sign_in_as_a_valid_user
  end

  describe 'GET /courses' do
    it 'works! (now write some real specs)' do
      get courses_path
      expect(response).to have_http_status(200)
    end
  end
end
