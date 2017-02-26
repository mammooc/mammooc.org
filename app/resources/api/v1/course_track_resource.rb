# frozen_string_literal: true

module Api
  module V1
    class CourseTrackResource < JSONAPI::Resource
      immutable

      attributes :costs, :costs_currency, :credit_points

      has_one :track_type, foreign_key: 'course_track_type_id'
      has_one :course
    end
  end
end
