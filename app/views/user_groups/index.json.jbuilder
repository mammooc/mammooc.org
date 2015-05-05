# encoding: utf-8
json.array!(@user_groups) do |user_group|
  json.extract! user_group, :id, :is_admin, :user_id, :group_id
  json.url user_group_url(user_group, format: :json)
end
