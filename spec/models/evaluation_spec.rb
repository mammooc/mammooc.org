# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Evaluation, type: :model do
  describe 'update_course_rating_and_count' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:course) { FactoryBot.create(:course) }
    let!(:evaluation) do
      FactoryBot.create(:full_evaluation,
        user: user,
        course: course,
        course_status: 1,
        rating: 1)
    end

    it 'call update_course_rating_and_count after save when rating changed' do
      expect(evaluation).to receive(:update_course_rating_and_count)
      evaluation.rating = 2
      evaluation.save!
    end

    it 'not call update_course_rating_and_count after save when nothing changed' do
      expect(evaluation).not_to receive(:update_course_rating_and_count)
      evaluation.save!
    end

    it 'not call update_course_rating_attributes when rating has not changed' do
      expect(Course).not_to receive(:update_course_rating_attributes).with(course.id)
      evaluation.description = 'changed'
      evaluation.course_status = 2
      evaluation.rating = 1
      evaluation.save!
    end

    it 'call update_course_rating_attributes when rating has changed' do
      expect(Course).to receive(:update_course_rating_attributes).with(course.id)
      evaluation.description = 'changed'
      evaluation.course_status = 2
      evaluation.rating = 2
      evaluation.save!
    end
  end

  describe 'collect_evaluation_objects_for_course' do
    it 'returns all evaluations for a course' do
      course =  FactoryBot.create(:course)
      evaluation1 = FactoryBot.create(:full_evaluation, course: course)
      evaluation2 = FactoryBot.create(:full_evaluation, course: course)
      FactoryBot.create(:full_evaluation)
      evaluations, = described_class.collect_evaluation_objects_for_course(course)
      expect(evaluations.first[:evaluation_id]).to eq evaluation1.id
      expect(evaluations.second[:evaluation_id]).to eq evaluation2.id
      expect(evaluations.count).to eq 2
    end

    it 'returns nil for the previous course if the evaluations are for the current course' do
      course =  FactoryBot.create(:course)
      FactoryBot.create(:full_evaluation, course: course)
      _, previous_course = described_class.collect_evaluation_objects_for_course(course)
      expect(previous_course).to be_nil
    end

    it 'does not return evaluations from a previous iteration if the current course have some' do
      course = FactoryBot.create(:course)
      previous_course = FactoryBot.create(:course)
      course.previous_iteration_id = previous_course.id
      course.save
      evaluation1 = FactoryBot.create(:full_evaluation, course: course)
      evaluation2 = FactoryBot.create(:full_evaluation, course: course)
      FactoryBot.create(:full_evaluation, course: previous_course)
      evaluations, = described_class.collect_evaluation_objects_for_course(course)
      expect(evaluations.first[:evaluation_id]).to eq evaluation1.id
      expect(evaluations.second[:evaluation_id]).to eq evaluation2.id
      expect(evaluations.count).to eq 2
    end

    it 'returns all evaluations for a previous course iteration' do
      course =  FactoryBot.create(:course)
      previous_course = FactoryBot.create(:course)
      course.previous_iteration_id = previous_course.id
      course.save
      evaluation1 = FactoryBot.create(:full_evaluation, course: previous_course)
      evaluation2 = FactoryBot.create(:full_evaluation, course: previous_course)
      evaluations, = described_class.collect_evaluation_objects_for_course(course)
      expect(evaluations.first[:evaluation_id]).to eq evaluation1.id
      expect(evaluations.second[:evaluation_id]).to eq evaluation2.id
    end

    it 'returns the previous course if there are evaluations for a previous iteration' do
      course =  FactoryBot.create(:course)
      previous_course = FactoryBot.create(:course)
      course.previous_iteration_id = previous_course.id
      course.save
      FactoryBot.create(:full_evaluation, course: previous_course)
      _, evaluations_for_previous_course = described_class.collect_evaluation_objects_for_course(course)
      expect(evaluations_for_previous_course).to eq previous_course
    end

    it 'returns nil if no evaluations are present' do
      course =  FactoryBot.create(:course)
      evaluations, evaluations_for_previous_course = described_class.collect_evaluation_objects_for_course(course)
      expect(evaluations).to be_nil
      expect(evaluations_for_previous_course).to be_nil
    end
  end

  describe 'evaluation_to_hash' do
    it 'returns a hash with all relevant values from an evaluations' do
      evaluation = FactoryBot.create(:full_evaluation, course_status: :finished)
      evaluation_hash = described_class.evaluation_to_hash(evaluation)
      expect(evaluation_hash[:evaluation_id]).to eq evaluation.id
      expect(evaluation_hash[:rating]).to eq evaluation.rating
      expect(evaluation_hash[:description]).to eq evaluation.description
      expect(evaluation_hash[:creation_date]).to eq evaluation.created_at
      expect(evaluation_hash[:total_feedback_count]).to eq evaluation.total_feedback_count
      expect(evaluation_hash[:positive_feedback_count]).to eq evaluation.positive_feedback_count
      expect(evaluation_hash[:course_status]).to eq I18n.t('evaluations.finished_course')
      expect(evaluation_hash[:user_id]).to eq evaluation.user.id
      expect(evaluation_hash[:user_name]).to eq "#{evaluation.user.first_name} #{evaluation.user.last_name}"
    end

    it 'sets the user to anonymous if the corresponding flag is set to true' do
      evaluation = FactoryBot.create(:full_evaluation, rated_anonymously: true)
      evaluation_hash = described_class.evaluation_to_hash(evaluation)
      expect(evaluation_hash[:user_id]).to be_nil
      expect(evaluation_hash[:user_name]).to eq I18n.t('evaluations.anonymous')
    end

    it 'translates the course status for :finished' do
      evaluation = FactoryBot.create(:full_evaluation, course_status: :finished)
      evaluation_hash = described_class.evaluation_to_hash(evaluation)
      expect(evaluation_hash[:course_status]).to eq I18n.t('evaluations.finished_course')
    end

    it 'translates the course status for :aborted' do
      evaluation = FactoryBot.create(:full_evaluation, course_status: :aborted)
      evaluation_hash = described_class.evaluation_to_hash(evaluation)
      expect(evaluation_hash[:course_status]).to eq I18n.t('evaluations.aborted_course')
    end

    it 'translates the course status for :enrolled' do
      evaluation = FactoryBot.create(:full_evaluation, course_status: :enrolled)
      evaluation_hash = described_class.evaluation_to_hash(evaluation)
      expect(evaluation_hash[:course_status]).to eq I18n.t('evaluations.currently_enrolled_course')
    end
  end

  describe 'collect_evaluations_from_a_previous_course_iteration' do
    let(:previous_course_iteration) { FactoryBot.create(:course) }
    let(:course) do
      course = FactoryBot.create(:course)
      course.previous_iteration_id = previous_course_iteration.id
      course.save
      course
    end

    it 'returns all evaluations for the previous course iteration' do
      FactoryBot.create(:full_evaluation, course: previous_course_iteration)
      FactoryBot.create(:full_evaluation, course: previous_course_iteration)
      evaluations, = described_class.collect_evaluations_from_a_previous_course_iteration(course)
      expect(evaluations).to eq previous_course_iteration.evaluations
    end

    it 'returns the previous course for which the evaluations are' do
      FactoryBot.create(:full_evaluation, course: previous_course_iteration)
      FactoryBot.create(:full_evaluation, course: previous_course_iteration)
      _, previous_course = described_class.collect_evaluations_from_a_previous_course_iteration(course)
      expect(previous_course).to eq previous_course_iteration
    end

    it 'returns the evaluations from the first previous iteration with evaluations' do
      previous_previous_course = FactoryBot.create(:course)
      previous_course_iteration.previous_iteration_id = previous_previous_course.id
      previous_course_iteration.save
      pre_pre_pre_course = FactoryBot.create(:course)
      previous_previous_course.previous_iteration_id = pre_pre_pre_course.id
      previous_previous_course.save
      FactoryBot.create(:full_evaluation, course: previous_previous_course)
      FactoryBot.create(:full_evaluation, course: previous_previous_course)
      FactoryBot.create(:full_evaluation, course: pre_pre_pre_course)
      FactoryBot.create(:full_evaluation, course: pre_pre_pre_course)
      evaluations, previous_course = described_class.collect_evaluations_from_a_previous_course_iteration(course)
      expect(previous_course).to eq previous_previous_course
      expect(evaluations).to eq previous_previous_course.evaluations
    end

    it 'returns nil if no previous iteration has evaluations' do
      evaluations, previous_course = described_class.collect_evaluations_from_a_previous_course_iteration(course)
      expect(previous_course).to be_nil
      expect(evaluations).to be_nil
    end
  end
end
