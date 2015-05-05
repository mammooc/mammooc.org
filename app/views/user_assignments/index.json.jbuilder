# encoding: utf-8
json.array!(@user_assignments) do |user_assignment|
  json.extract! user_assignment, :id, :date, :score, :user_id, :course_id, :course_assignment_id
  json.url user_assignment_url(user_assignment, format: :json)
end
