# encoding: utf-8
json.array!(@comments) do |comment|
  json.extract! comment, :id, :date, :content, :user_id, :recommendation_id
  json.url comment_url(comment, format: :json)
end
