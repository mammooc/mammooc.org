# frozen_string_literal: true

json.array!(@mooc_providers) do |mooc_provider|
  json.extract! mooc_provider, :id, :logo_id, :name, :url, :description, :api_support_state
  json.url mooc_provider_url(mooc_provider, format: :json)
end
