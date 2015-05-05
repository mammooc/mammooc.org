# encoding: utf-8
json.array!(@progresses) do |progress|
  json.extract! progress, :id, :percentage, :permissions, :course_id, :user_id
  json.url progress_url(progress, format: :json)
end
