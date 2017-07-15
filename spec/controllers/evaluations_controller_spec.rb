# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EvaluationsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user
  end

  describe 'POST process_feedback' do
    let(:evaluation) { FactoryGirl.create(:full_evaluation) }
    let(:own_evaluation) { FactoryGirl.create(:full_evaluation, user_id: user.id) }

    it 'increases rating_count by one when evaluation is marked as not helpful' do
      total_feedback_count = evaluation.total_feedback_count
      positive_feedback_count = evaluation.positive_feedback_count
      post :process_feedback, params: {id: evaluation.id, helpful: 'false'}
      evaluation.reload
      expect(evaluation.total_feedback_count).to eq(total_feedback_count + 1)
      expect(evaluation.positive_feedback_count).to eq(positive_feedback_count)
    end

    it 'increases rating_count and helpful_rating_count by one when evaluation is marked as helpful' do
      total_feedback_count = evaluation.total_feedback_count
      positive_feedback_count = evaluation.positive_feedback_count
      post :process_feedback, params: {id: evaluation.id, helpful: 'true'}
      evaluation.reload
      expect(evaluation.total_feedback_count).to eq(total_feedback_count + 1)
      expect(evaluation.positive_feedback_count).to eq(positive_feedback_count + 1)
    end

    it 'does not increase anything when rated an own evaluation' do
      total_feedback_count = own_evaluation.total_feedback_count
      positive_feedback_count = own_evaluation.positive_feedback_count
      post :process_feedback, params: {id: own_evaluation.id, helpful: 'true'}
      own_evaluation.reload
      expect(own_evaluation.total_feedback_count).not_to eq(total_feedback_count + 1)
      expect(own_evaluation.positive_feedback_count).not_to eq(positive_feedback_count + 1)
    end
  end

  describe 'GET export' do
    let!(:mooc_provider) { MoocProvider.create(name: 'openHPI', logo_id: 'logo_openHPI.svg', url: 'https://example.com', api_support_state: :naive) }
    let!(:other_mooc_provider) { MoocProvider.create(name: 'openSAP', logo_id: 'logo_openSAP.svg', url: 'https://example.com', api_support_state: :naive) }
    let!(:course) { FactoryGirl.create(:course, mooc_provider: mooc_provider) }
    let!(:evaluation) { FactoryGirl.create(:full_evaluation, course: course, rating: 5) }
    let!(:evaluation2) { FactoryGirl.create(:full_evaluation, course: course, rating: 10) }
    let!(:evaluation12) { FactoryGirl.create(:full_evaluation, course: course, rating: 6) }

    let!(:course2) { FactoryGirl.create(:course, mooc_provider: mooc_provider) }
    let!(:evaluation3) { FactoryGirl.create(:full_evaluation, course: course2, rating: 2) }
    let!(:other_course) { FactoryGirl.create(:course, mooc_provider: other_mooc_provider) }
    let!(:evaluation4) { FactoryGirl.create(:full_evaluation, course: other_course, rating: 4) }

    render_views
    context 'export_course_evaluations' do
      context 'specify course' do
        subject(:evaluations) { JSON.parse(response.body)['evaluations'].first['user_evaluations'] }

        it 'returns all evaluations for specific course and specific provider' do
          get :export_course_evaluations, params: {format: :json, provider: mooc_provider.name, course_id: course.provider_course_id}
          expect(evaluations.first['rating']).to eq evaluation.rating
          expect(evaluations.second['rating']).to eq evaluation2.rating
          expect(evaluations.third['rating']).to eq evaluation12.rating
          expect(evaluations.count).to eq 3
        end

        it 'returns first page of evaluations for specific course and specific provider' do
          get :export_course_evaluations, params: {format: :json, provider: mooc_provider.name, course_id: course.provider_course_id, per_page: 2, page: 1}
          expect(evaluations.first['rating']).to eq evaluation.rating
          expect(evaluations.second['rating']).to eq evaluation2.rating
          expect(evaluations.count).to eq 2
        end

        it 'returns specific page of evaluations for specific course and specific provider' do
          get :export_course_evaluations, params: {format: :json, provider: mooc_provider.name, course_id: course.provider_course_id, per_page: 1, page: 3}
          expect(evaluations.first['rating']).to eq evaluation12.rating
          expect(evaluations.count).to eq 1
        end
      end

      context 'error' do
        subject(:error_message) { JSON.parse(response.body)['error'] }

        it 'raises error if only course_id is given' do
          get :export_course_evaluations, params: {format: :json, course_id: course.provider_course_id}
          expect(error_message).to include 'no provider given for the course'
        end

        it 'returns an error if specific course is not present ' do
          get :export_course_evaluations, params: {format: :json, provider: mooc_provider.name, course_id: '12345678901'}
          expect(error_message).to eq "Couldn't find Course"
        end

        it 'returns an error if specific provider is not present ' do
          get :export_course_evaluations, params: {format: :json, provider: 'assdaddsdad', course_id: course.provider_course_id}
          expect(error_message).to eq "Couldn't find MoocProvider"
        end
      end
    end

    context 'export_overall_course_rating' do
      context 'specify course' do
        subject(:evaluations) { JSON.parse(response.body)['evaluations'] }

        it 'returns the number of all evaluations for specific course and specific provider' do
          get :export_overall_course_rating, params: {format: :json, provider: mooc_provider.name, course_id: course.provider_course_id}
          expect(evaluations['number_of_evaluations']).to eq 3
        end

        it 'returns overall rating for specific course and specific provider' do
          get :export_overall_course_rating, params: {format: :json, provider: mooc_provider.name, course_id: course.provider_course_id, per_page: 1}
          expect(evaluations['overall_rating']).to eq 7.0
        end
      end

      context 'error' do
        subject(:error_message) { JSON.parse(response.body)['error'] }

        it 'raises error if only course_id is given' do
          get :export_overall_course_rating, params: {format: :json, course_id: course.provider_course_id}
          expect(error_message).to include 'no provider given for the course'
        end

        it 'returns an error if specific course is not present ' do
          get :export_overall_course_rating, params: {format: :json, provider: mooc_provider.name, course_id: '12345678901'}
          expect(error_message).to eq "Couldn't find Course"
        end

        it 'returns an error if specific provider is not present ' do
          get :export_overall_course_rating, params: {format: :json, provider: 'assdaddsdad', course_id: course.provider_course_id}
          expect(error_message).to eq "Couldn't find MoocProvider"
        end
      end
    end
  end
end
