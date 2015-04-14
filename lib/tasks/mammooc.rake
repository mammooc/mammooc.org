namespace :mammooc do
  task update_course_data: :environment do
    OpenHPICourseWorker.perform_async
    OpenSAPCourseWorker.perform_async
    CourseraCourseWorker.perform_async
    # OpenUNECourseWorker.perform_async
    # MoocHouseCourseWorker.perform_async
    # OpenSAPChinaCourseWorker.perform_async
    # OpenHPIChinaCourseWorker.perform_async
    EdxCourseWorker.perform_async
  end

  task update_user_data: :environment do
    OpenHPIUserWorker.perform_async nil
  end

end
