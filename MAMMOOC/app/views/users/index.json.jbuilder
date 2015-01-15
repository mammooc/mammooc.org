json.array!(@users) do |user|
  json.extract! user, :id, :id, :firstName, :lastName, :title, :password, :profileImageId, :emailSettings, :aboutMe
  json.url user_url(user, format: :json)
end
