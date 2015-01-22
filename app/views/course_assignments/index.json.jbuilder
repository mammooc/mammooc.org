json.array!(@course_assignments) do |course_assignment|
  json.extract! course_assignment, :id, :name, :deadline, :maximum_score, :average_score, :course_id
  json.url course_assignment_url(course_assignment, format: :json)
end
