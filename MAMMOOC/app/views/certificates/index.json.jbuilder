json.array!(@certificates) do |certificate|
  json.extract! certificate, :id, :title, :file_id, :completion_id
  json.url certificate_url(certificate, format: :json)
end
