# encoding: utf-8
# frozen_string_literal: true

json.array!(@all_courses) do |course|
  json.extract! course, :id, :name
end
