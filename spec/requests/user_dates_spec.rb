require 'rails_helper'

RSpec.describe 'UserDates', type: :request do
  describe 'get_my_dates' do
    let!(:user) { FactoryGirl.create(:user, token_for_user_dates: '1234') }

    it 'is possible to get get_my_dates without login with valid token' do
      get '/user_dates/get_my_dates/1234', format: :ics
      expect(response).to have_http_status(200)
    end

    it 'returns status 404 when getting get_my_dates without valid token' do
      get '/user_dates/get_my_dates/4321', format: :ics
      expect(response).to have_http_status(404)
    end

    it 'is possible to get get_my_dates when logged in with valid token' do
      login_as(user, scope: :user)
      get '/user_dates/get_my_dates/1234', format: :ics
      expect(response).to have_http_status(200)
    end

    it 'returns status 404 when getting get_my_dates when logged in without valid token' do
      login_as(user, scope: :user)
      get '/user_dates/get_my_dates/4321', format: :ics
      expect(response).to have_http_status(404)
    end

  end
end
