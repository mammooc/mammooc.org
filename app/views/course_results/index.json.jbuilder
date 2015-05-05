# encoding: utf-8
json.array!(@course_results) do |course_result|
  json.extract! course_result, :id, :maximum_score, :average_score, :best_score
  json.url course_result_url(course_result, format: :json)
end
