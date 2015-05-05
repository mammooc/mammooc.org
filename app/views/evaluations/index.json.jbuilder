# encoding: utf-8
json.array!(@evaluations) do |evaluation|
  json.extract! evaluation, :id, :title, :rating, :is_verified, :description, :date, :user_id, :course_id
  json.url evaluation_url(evaluation, format: :json)
end
