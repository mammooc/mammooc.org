namespace :mammooc do
  task update_course_data: :environment do
    OpenHPICourseWorker.perform_async
    OpenSAPCourseWorker.perform_async
    CoseraCourseWorker.perform_async
  end

end
