# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:mooc_provider) { FactoryBot.create(:mooc_provider, name: 'open_mammooc') }
  let!(:course) { FactoryBot.create(:course, mooc_provider: mooc_provider) }
  let!(:second_mooc_provider) { FactoryBot.create(:mooc_provider, name: 'openHPI') }
  let!(:second_course) { FactoryBot.create(:course, mooc_provider: second_mooc_provider) }
  let!(:third_mooc_provider) { FactoryBot.create(:mooc_provider, name: 'coursera') }
  let!(:third_course) { FactoryBot.create(:course, mooc_provider: third_mooc_provider) }

  before do
    sign_in user
  end

  describe 'GET filter_options' do
    render_views

    it 'responds with valid json' do
      session['course_filterrific'] = {with_language: 'en', duration_filter_options: 'short'}
      expected_response = {with_language: 'en', duration_filter_options: 'short'}.to_query('filterrific')
      get :filter_options, params: {format: :json}
      expect(JSON.parse(response.body)['filter_options']).to eq expected_response
    end
  end

  describe 'GET search' do
    it 'set session variable "courses#index" to the given param' do
      get :search, params: {query: 'web'}
      expect(session['course_filterrific']).to eq(search_query: 'web')
    end

    it 'redirects to courses_path' do
      get :search, params: {query: 'web'}
      expect(response).to redirect_to courses_path
    end
  end

  describe 'GET autocomplete' do
    let(:web_course) { FactoryBot.create :course, name: 'Web Stuff' }

    it 'responds with filtered courses' do
      get :autocomplete, params: {format: :json, q: 'web'}
      expect(assigns(:courses)).to match_array([web_course])
    end
  end

  describe 'GET index' do
    let(:course2) { FactoryBot.create(:course, language: 'en', calculated_duration_in_days: 20) }

    it 'assigns all courses as @courses' do
      get :index, params: {}
      expect(assigns(:courses)).to match_array([course, second_course, third_course])
    end

    it 'filters the courses after given parameters in URL' do
      course2
      get :index, params: {filterrific: {with_language: 'en', duration_filter_options: 'short'}}
      expect(assigns(:courses)).to eq([course2])
    end

    it 'filters courses out after given parameters in URL' do
      course2
      get :index, params: {filterrific: {with_language: 'de', duration_filter_options: 'short'}}
      expect(assigns(:courses)).to eq([])
    end
  end

  describe 'GET show' do
    it 'assigns the requested course as @course' do
      get :show, params: {id: course.to_param}
      expect(assigns(:course)).to eq(course)
    end

    it 'assigns the requested course as @course ~or provider given IDs' do
      get :show, params: {id: "#{course.mooc_provider.name}~#{course.provider_course_id}"}
      expect(assigns(:course)).to eq(course)
    end
  end

  describe 'GET enroll_course' do
    it 'assigns nil as @has_enrolled if no provider connector is present' do
      get :enroll_course, params: {id: course.to_param}
      expect(assigns(:has_enrolled)).to eq nil
    end

    it 'assigns nil as @has_enrolled if a provider connector is present but does not support to create enrollments' do
      FactoryBot.create(:oauth_mooc_provider_user, user: user, mooc_provider: third_mooc_provider)
      get :enroll_course, params: {id: third_course.to_param}
      expect(assigns(:has_enrolled)).to eq nil
    end

    it 'assigns false as @has_enrolled if a connector is present but user has no connection' do
      get :enroll_course, params: {id: second_course.to_param}
      expect(assigns(:has_enrolled)).to eq false
    end

    it 'assigns true as @has_enrolled if everything was ok' do
      allow_any_instance_of(OpenHPIConnector).to receive(:enroll_user_for_course).and_return(true)
      get :enroll_course, params: {id: second_course.to_param}
      expect(assigns(:has_enrolled)).to eq true
    end

    it 'creates an enrollment-activity if everything was ok' do
      allow_any_instance_of(OpenHPIConnector).to receive(:enroll_user_for_course).and_return(true)
      expect do
        get :enroll_course, params: {id: second_course.to_param}
      end.to change(PublicActivity::Activity, :count).by(1)
    end
  end

  describe 'GET unenroll_course' do
    it 'assigns nil as @has_unenrolled if no provider connector is present' do
      get :unenroll_course, params: {id: course.to_param}
      expect(assigns(:has_unenrolled)).to eq nil
    end

    it 'assigns nil as @has_unenrolled if a provider connector is present but does not support to delete enrollments' do
      FactoryBot.create(:oauth_mooc_provider_user, user: user, mooc_provider: third_mooc_provider)
      get :unenroll_course, params: {id: third_course.to_param}
      expect(assigns(:has_unenrolled)).to eq nil
    end

    it 'assigns false as @has_unenrolled if a connector is present but user has no connection' do
      get :unenroll_course, params: {id: second_course.to_param}
      expect(assigns(:has_unenrolled)).to eq false
    end

    it 'assigns true as @has_unenrolled if everything was ok' do
      allow_any_instance_of(OpenHPIConnector).to receive(:unenroll_user_for_course).and_return(true)
      get :unenroll_course, params: {id: second_course.to_param}
      expect(assigns(:has_unenrolled)).to eq true
    end
  end

  describe 'POST send_evaluation' do
    let(:evaluation) do
      FactoryBot.create(:full_evaluation, user_id: user.id, course_id: course.id,
                                          rating: 1,
                                          course_status: :aborted,
                                          rated_anonymously: false,
                                          description: 'blub blub')
    end

    it 'throws an error when rating is not within accepted range' do
      post :send_evaluation, params: {rating: -5, id: course.id}
      expect(assigns(:errors)).not_to be_empty
    end

    it 'throws an error when course_status is not within accepted range' do
      post :send_evaluation, params: {course_status: -5, id: course.id}
      expect(assigns(:errors)).not_to be_empty
    end

    it 'creates a new evaluation when params are correct and no evaluation is present yet' do
      expect { post :send_evaluation, params: {rating: 1, course_status: :enrolled, id: course.id} }.to change { Evaluation.count }.by(1)
    end

    it 'does not create a new evaluation when it is already present' do
      evaluation.save
      expect { post :send_evaluation, params: {rating: 2, course_status: :finished, id: course.id} }.not_to change(Evaluation, :count)
    end

    it 'updates the evaluation when params are correct and evaluation is already present' do
      evaluation.save
      post :send_evaluation, params: {rating: 2, course_status: :finished, rate_anonymously: true, rating_textarea: 'blub', id: course.id}
      evaluation.reload
      expect(evaluation.rating).to eq(2)
      expect(evaluation.course_status).to eq(:finished.to_s)
      expect(evaluation.rated_anonymously).to eq(true)
      expect(evaluation.description).to eq('blub')
    end
  end
end
