# frozen_string_literal: true

json.array!(@groups) do |group|
  json.extract! group, :id, :name, :image, :description, :primary_statistics
  json.url group_url(group, format: :json)
end
