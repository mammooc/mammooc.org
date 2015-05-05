# encoding: utf-8
json.array!(@groups) do |group|
  json.extract! group, :id, :name, :image_id, :description, :primary_statistics
  json.url group_url(group, format: :json)
end
