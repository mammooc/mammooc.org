# frozen_string_literal: true

module Api
  module V1
    class CourseTrackTypeResource < JSONAPI::Resource
      immutable

      attributes :type_of_achievement, :title, :description
    end
  end
end
