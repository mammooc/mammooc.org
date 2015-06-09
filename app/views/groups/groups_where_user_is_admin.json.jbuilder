# encoding: utf-8
json.array!(@admin_groups) do |group|
  json.extract! group, :id, :name
end
