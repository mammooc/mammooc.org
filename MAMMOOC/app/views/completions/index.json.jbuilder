json.array!(@completions) do |completion|
  json.extract! completion, :id, :position_in_course, :points, :permissions, :date, :user_id, :course_id
  json.url completion_url(completion, format: :json)
end
