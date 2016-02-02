# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Evaluation, type: :model do
  describe 'update_course_rating_and_count' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:course) { FactoryGirl.create(:course) }
    let!(:evaluation) do
      FactoryGirl.create(:full_evaluation,
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
      expect(evaluation).to_not receive(:update_course_rating_and_count)
      evaluation.save!
    end

    it 'not call update_course_rating_attributes when rating has not changed' do
      expect(Course).to_not receive(:update_course_rating_attributes).with(course.id)
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
end
