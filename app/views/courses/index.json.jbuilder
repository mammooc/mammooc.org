json.array!(@courses) do |course|
  json.extract! course, :id, :name, :url, :course_instructors, :abstract, :language, :imageId, :videoId, :start_date, :end_date, :calculated_duration_in_days, :provider_given_duration, :costs, :type_of_achievement, :categories, :difficulty, :requirements, :workload, :provider_course_id, :mooc_provider_id, :course_result_id, :subtitle_languages, :previous_iteration_id, :following_iteration_id, :open_for_registration, :price_currency, :credit_points
  json.url course_url(course, format: :json)
end
