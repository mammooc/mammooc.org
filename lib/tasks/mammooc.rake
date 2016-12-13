# encoding: utf-8
# frozen_string_literal: true

namespace :mammooc do
  task update_course_data: :environment do
    OpenHPICourseWorker.perform_async
    OpenSAPCourseWorker.perform_async
    CourseraCourseWorker.perform_async
    OpenUNECourseWorker.perform_async
    MoocHouseCourseWorker.perform_async
    OpenHPIChinaCourseWorker.perform_async
    EdxCourseWorker.perform_async
    IversityCourseWorker.perform_async
    UdacityCourseWorker.perform_async
    FutureLearnCourseWorker.perform_async
  end

  task update_user_data: :environment do
    OpenHPIUserWorker.perform_async
    OpenSAPUserWorker.perform_async
    OpenUNEUserWorker.perform_async
    MoocHouseUserWorker.perform_async
    OpenHPIChinaUserWorker.perform_async
    CourseraUserWorker.perform_async
  end

  task send_reminders: :environment do
    BookmarkWorker.perform_async
  end

  task send_newsletters: :environment do
    NewsletterWorker.perform_async
  end

  task synchronize_dates_for_all_users: :environment do
    UserDatesWorker.perform_async
  end

end
