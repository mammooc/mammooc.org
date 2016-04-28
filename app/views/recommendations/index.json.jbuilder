# encoding: utf-8
# frozen_string_literal: true

json.array!(@recommendations) do |recommendation|
  json.extract! recommendation, :id, :is_obligatory, :user_id, :group_id, :course_id
  json.url recommendation_url(recommendation, format: :json)
end
