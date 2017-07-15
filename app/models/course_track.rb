# frozen_string_literal: true

class CourseTrack < ApplicationRecord
  belongs_to :track_type, class_name: 'CourseTrackType', foreign_key: 'course_track_type_id'
  belongs_to :course

  validate :costs_completeness

  private

  def costs_completeness
    (costs && costs_currency) || (costs.nil? && costs_currency.nil?)
  end
end
