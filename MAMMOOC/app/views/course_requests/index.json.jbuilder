json.array!(@course_requests) do |course_request|
  json.extract! course_request, :id, :date, :description, :course_id, :user_id, :group_id
  json.url course_request_url(course_request, format: :json)
end
