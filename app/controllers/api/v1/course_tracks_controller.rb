# frozen_string_literal: true

module Api
  module V1
    class CourseTracksController < JSONAPI::ResourceController
      protect_from_forgery with: :null_session
    end
  end
end
