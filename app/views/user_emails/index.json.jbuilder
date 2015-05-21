# encoding: utf-8
json.array!(@user_email) do |email|
  json.extract! email, :id, :address, :is_primary, :user_id, :is_verified
  json.url user_email_url(email, format: :json)
end
