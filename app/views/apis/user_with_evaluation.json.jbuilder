json.logged_in @logged_in
json.user @user
json.evaluation do
  json.extract! @evaluation, :rating, :is_verified, :description, :course_status, :rated_anonymously
end