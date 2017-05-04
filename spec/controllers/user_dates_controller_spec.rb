# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDatesController, type: :controller do
  let(:user) { FactoryGirl.create(:user, token_for_user_dates: '1234567890') }
  let(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openHPI') }
  let(:course) { FactoryGirl.create(:course, mooc_provider: mooc_provider) }
  let(:valid_attributes) { {user_id: user.id, course_id: course.id, date: Time.zone.now, title: 'Assignment 1', kind: 'submission deadline', relevant: true} }

  before do
    sign_in user
    user.courses.push(course)
  end

  describe 'GET #index' do
    it 'assigns all user_dates as @user_dates' do
      user_date = UserDate.create! valid_attributes
      get :index
      expect(assigns(:user_dates)).to eq([user_date])
    end
  end

  describe 'GET events_for_calendar_view' do
    it 'assigns dates from user in the specified time period to @current_user_dates' do
      user_date = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now + 1.day)
      get :events_for_calendar_view, params: {start: Time.zone.now, end: Time.zone.now + 2.days, format: :json}
      expect(assigns(:current_user_dates)).to eq([user_date])
    end

    it 'does not assign dates from user which are not in the specified time period to @current_user_dates' do
      user_date = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now + 1.day)
      old_user_date = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now - 1.day)
      future_user_date = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now + 5.days)
      get :events_for_calendar_view, params: {start: Time.zone.now, end: Time.zone.now + 2.days, format: :json}
      expect(assigns(:current_user_dates)).to eq([user_date])
      expect(assigns(:current_user_dates)).not_to include(old_user_date)
      expect(assigns(:current_user_dates)).not_to include(future_user_date)
    end
  end

  describe 'GET synchronize_dates_on_dashboard' do
    render_views
    it 'assings synchronization_state to @synchronization_state' do
      expect(UserDate).to receive(:synchronize).with(user).and_return(true).once
      get :synchronize_dates_on_dashboard, params: {format: :json}
      expect(assigns(:synchronization_state)).to eq(true)
    end

    it 'assings partial to @partial, partial include user_date' do
      user_date = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now + 1.day)
      expect(UserDate).to receive(:synchronize).with(user).and_return(true).once
      get :synchronize_dates_on_dashboard, params: {format: :json}
      expect(assigns(:partial)).to include(user_date.title)
    end

    it 'assings partial to @partial, partial includes no user date' do
      expect(UserDate).to receive(:synchronize).with(user).and_return(true).once
      get :synchronize_dates_on_dashboard, params: {format: :json}
      expect(assigns(:partial)).to include(I18n.t('dashboard.no_current_dates'))
    end

    it 'assings the first three current dates of user to @current_dates_to_show' do
      user_date1 = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now)
      user_date2 = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now + 1.day)
      user_date3 = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now + 4.days)
      user_date4 = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now + 8.days)
      expect(UserDate).to receive(:synchronize).with(user).and_return(true).once
      get :synchronize_dates_on_dashboard, params: {format: :json}
      expect(assigns(:current_dates_to_show)).to match_array([user_date1, user_date2, user_date3])
      expect(assigns(:current_dates_to_show)).not_to include(user_date4)
    end

    it 'does not assign an old date to @current_dates_to_show' do
      old_user_date = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now - 1.day)
      FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now)
      expect(UserDate).to receive(:synchronize).with(user).and_return(true).once
      get :synchronize_dates_on_dashboard, params: {format: :json}
      expect(assigns(:current_dates_to_show)).not_to include(old_user_date)
    end
  end

  describe 'GET synchronize_dates_on_index_page' do
    it 'assings synchronization_state to @synchronization_state' do
      expect(UserDate).to receive(:synchronize).with(user).and_return(true).once
      get :synchronize_dates_on_index_page, params: {format: :json}
      expect(assigns(:synchronization_state)).to eq(true)
    end
  end

  describe 'GET create_calendar_feed' do
    it 'renders calendar feed including user_date' do
      user_date = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now)
      get :create_calendar_feed, params: {format: :ics}
      expect(response.body).to include(user_date.title)
    end
  end

  describe 'GET my_dates' do
    it 'renders calendar feed including user_date' do
      user_date = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now)
      get :my_dates, format: :ics, params: {token: user.token_for_user_dates}
      expect(response.body).to include(user_date.title)
    end

    it 'renders calendar feed for correct user' do
      user2 = FactoryGirl.create(:user, token_for_user_dates: '987654321')
      user_date = FactoryGirl.create(:user_date, user: user, course: course, date: Time.zone.now, title: 'correct event')
      user_date2 = FactoryGirl.create(:user_date, user: user2, course: course, date: Time.zone.now, title: 'wrong event')
      get :my_dates, format: :ics, params: {token: user.token_for_user_dates}
      expect(response.body).to include(user_date.title)
      expect(response.body).not_to include(user_date2.title)
    end

    it 'renders 404 if token is invalid' do
      get :my_dates, params: {format: :ics, token: 'noValidToken'}
      expect(response.body).to include('Not Found')
    end
  end
end
