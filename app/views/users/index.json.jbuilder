json.array!(@users) do |user|
  json.extract! user, :id, :first_name, :last_name, :title, :password, :profile_image_id, :email_settings, :about_me
  json.url user_url(user, format: :json)
end
