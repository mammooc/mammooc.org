# frozen_string_literal: true

json.array!(@user_dates) do |user_date|
  json.extract! user_date, :id, :user_id, :course_id, :date, :title, :kind, :relevant, :ressource_id_from_provider
  json.url user_date_url(user_date, format: :json)
end
