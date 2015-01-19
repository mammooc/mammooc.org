json.array!(@statistics) do |statistic|
  json.extract! statistic, :id, :name, :result, :group_id
  json.url statistic_url(statistic, format: :json)
end
