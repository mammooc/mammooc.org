json.array!(@user_dates) do |user_date|
  json.extract! user_date, :id, :user_id, :course_id, :mooc_provider_id, :date, :title, :kind, :relevant, :ressource_id_from_provider
  json.url user_date_url(user_date, format: :json)
end
