json.array!(@groups) do |group|
  json.extract! group, :id, :name, :imageId, :description, :primary_statistics
  json.url group_url(group, format: :json)
end
