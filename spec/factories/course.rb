FactoryGirl.define do

  factory :course do
    name 'Web Technologies'
    url 'course@test.com'
    start_date DateTime.new(2016,02,16,8)
    end_date DateTime.new(2016,02,28,20)
    provider_course_id 5
  end
end
