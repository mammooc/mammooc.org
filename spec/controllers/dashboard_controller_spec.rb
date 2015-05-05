# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    sign_in user
  end

  describe 'GET dashboard' do
    it 'returns http success' do
      get :dashboard
      expect(response).to have_http_status(:success)
    end
  end
end
