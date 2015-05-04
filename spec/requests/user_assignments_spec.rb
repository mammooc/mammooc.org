# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'UserAssignments', type: :request do
  before(:each) do
    sign_in_as_a_valid_user
  end

  describe 'GET /user_assignments' do
    it 'works! (now write some real specs)' do
      get user_assignments_path
      expect(response).to have_http_status(200)
    end
  end
end
