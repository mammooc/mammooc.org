# encoding: utf-8
# frozen_string_literal: true

json.array!(@completions) do |completion|
  json.extract! completion, :id, :quantile, :points_achieved, :provider_percentage, :user_id, :course_id
  json.certificates do
    json.array!(completion.certificates) do |certificate|
      json.extract! certificate, :id, :title, :document_type, :download_url, :verification_url
    end
  end
end
