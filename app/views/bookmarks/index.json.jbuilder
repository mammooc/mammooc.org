# frozen_string_literal: true

json.array!(@bookmarks) do |bookmark|
  json.extract! bookmark, :id, :user_id, :course_id
  json.url bookmark_url(bookmark, format: :json)
end
