# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserDatesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/user_dates').to route_to('user_dates#index')
    end

    it 'routes to #synchronize_dates_on_dashboard' do
      expect(get: 'user_dates/synchronize_dates_on_dashboard').to route_to('user_dates#synchronize_dates_on_dashboard')
    end

    it 'routes to #synchronize_dates_on_index_page' do
      expect(get: 'user_dates/synchronize_dates_on_index_page').to route_to('user_dates#synchronize_dates_on_index_page')
    end

    it 'routes to #calendar_feed' do
      expect(get: 'user_dates/calendar_feed').to route_to('user_dates#create_calendar_feed')
    end

    it 'route to #_my_dates' do
      expect(get: 'user_dates/my_dates/1234').to route_to('user_dates#my_dates', token: '1234')
    end

    it 'routes to #events_for_calendar_view' do
      expect(get: 'user_dates/events_for_calendar_view').to route_to('user_dates#events_for_calendar_view')
    end
  end
end
