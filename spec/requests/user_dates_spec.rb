# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserDates', type: :request do
  describe 'my_dates' do
    let!(:user) { FactoryBot.create(:user, token_for_user_dates: '1234') }

    it 'is possible to get my_dates without login with valid token' do
      get '/user_dates/my_dates/1234', params: {format: :ics}
      expect(response).to have_http_status(:ok)
    end

    it 'returns status 404 when getting my_dates without valid token' do
      get '/user_dates/my_dates/4321', params: {format: :ics}
      expect(response).to have_http_status(:not_found)
    end

    it 'is possible to get my_dates when logged in with valid token' do
      login_as(user, scope: :user)
      get '/user_dates/my_dates/1234', params: {format: :ics}
      expect(response).to have_http_status(:ok)
    end

    it 'returns status 404 when getting my_dates when logged in without valid token' do
      login_as(user, scope: :user)
      get '/user_dates/my_dates/4321', params: {format: :ics}
      expect(response).to have_http_status(:not_found)
    end
  end
end
