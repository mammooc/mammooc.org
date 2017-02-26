# frozen_string_literal: true

module Api
  module V1
    class CourseResource < JSONAPI::Resource
      include Rails.application.routes.url_helpers

      immutable

      attributes :name, :url, :abstract, :language, :videoId, :start_date, :end_date, :difficulty, :provider_course_id, :created_at, :updated_at, :categories, :requirements, :course_instructors, :description, :open_for_registration, :workload, :subtitle_languages, :calculated_duration_in_days, :provider_given_duration, :calculated_rating, :rating_count, :points_maximal, :course_image_file_name, :course_image_content_type, :course_image_file_size, :course_image_updated_at

      attribute :course_image_url

      def course_image_url
        @model.course_image.url
      end

      def custom_links(_options)
        {url: mammooc_url}
      end

      def mammooc_url
        Settings.root_url + course_path(@model.id)
      end

      has_one :mooc_provider
      has_one :previous_iteration, class_name: 'Course'
      has_one :following_iteration, class_name: 'Course'
      has_one :organisation

      has_many :tracks, class_name: 'CourseTrack'
    end
  end
end
