# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApisController, type: :controller do
  describe 'GET #statistics' do
    it 'returns http success even when not being logged in' do
      get :statistics, format: :js
      expect(response).to have_http_status(:success)
    end

    it 'returns a valid JSON with one key' do
      get :statistics, format: :js
      expect(JSON.parse(response.body)).to have_key('global_statistic')
      expect(JSON.parse(response.body).keys.count).to eq 1
    end

    context 'global_statistic' do
      subject(:statistics) { JSON.parse(response.body)['global_statistic'] }

      let!(:user_8days) { FactoryGirl.create(:user, created_at: Time.zone.now - 8.days) }
      let!(:user_4days) { FactoryGirl.create(:user, created_at: Time.zone.now - 4.days) }
      let!(:user_3hours) { FactoryGirl.create(:user, created_at: Time.zone.now - 3.hours) }

      it 'returns the correct amount of users' do
        get :statistics, format: :js

        expect(subject['users']).to eq 3
        expect(subject['users_last_day']).to eq 1
        expect(subject['users_last_7days']).to eq 2
      end
    end
  end
end
