# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiConnectionController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
