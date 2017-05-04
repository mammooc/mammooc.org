# frozen_string_literal: true

json.array!(@admin_groups) do |group|
  json.extract! group, :id, :name
end
