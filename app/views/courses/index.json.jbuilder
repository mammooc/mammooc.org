json.array!(@courses) do |course|
  json.extract! course, :id, :name, :url, :course_instructor, :abstract, :language, :imageId, :videoId, :start_date, :end_date, :duration, :costs, :type_of_achievement, :categories, :difficulty, :requirements, :workload, :provider_course_id, :mooc_provider_id, :course_result_id, :has_paid_version, :has_free_version
  json.url course_url(course, format: :json)
end
