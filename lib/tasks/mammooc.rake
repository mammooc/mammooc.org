namespace :mammooc do
  desc "TODO"
  task update_course_data: :environment do
    OpenHPICourseWorker.perform_async
  end

end
