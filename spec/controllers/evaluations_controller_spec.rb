# frozen_string_literal: true
require 'rails_helper'

RSpec.describe EvaluationsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    sign_in user
  end

  describe 'POST process_feedback' do
    let(:evaluation) { FactoryGirl.create(:full_evaluation) }
    let(:own_evaluation) { FactoryGirl.create(:full_evaluation, user_id: user.id) }

    it 'increases rating_count by one when evaluation is marked as not helpful' do
      total_feedback_count = evaluation.total_feedback_count
      positive_feedback_count = evaluation.positive_feedback_count
      post :process_feedback, id: evaluation.id, helpful: 'false'
      evaluation.reload
      expect(evaluation.total_feedback_count).to eq(total_feedback_count + 1)
      expect(evaluation.positive_feedback_count).to eq(positive_feedback_count)
    end

    it 'increases rating_count and helpful_rating_count by one when evaluation is marked as helpful' do
      total_feedback_count = evaluation.total_feedback_count
      positive_feedback_count = evaluation.positive_feedback_count
      post :process_feedback, id: evaluation.id, helpful: 'true'
      evaluation.reload
      expect(evaluation.total_feedback_count).to eq(total_feedback_count + 1)
      expect(evaluation.positive_feedback_count).to eq(positive_feedback_count + 1)
    end

    it 'does not increase anything when rated an own evaluation' do
      total_feedback_count = own_evaluation.total_feedback_count
      positive_feedback_count = own_evaluation.positive_feedback_count
      post :process_feedback, id: own_evaluation.id, helpful: 'true'
      own_evaluation.reload
      expect(own_evaluation.total_feedback_count).not_to eq(total_feedback_count + 1)
      expect(own_evaluation.positive_feedback_count).not_to eq(positive_feedback_count + 1)
    end
  end
end
