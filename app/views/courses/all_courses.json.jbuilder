# encoding: utf-8
json.array!(@all_courses) do |course|
  json.extract! course, :id, :name
end
