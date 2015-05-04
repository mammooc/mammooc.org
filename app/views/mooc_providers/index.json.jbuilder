# encoding: utf-8
json.array!(@mooc_providers) do |mooc_provider|
  json.extract! mooc_provider, :id, :logo_id, :name, :url, :description
  json.url mooc_provider_url(mooc_provider, format: :json)
end
