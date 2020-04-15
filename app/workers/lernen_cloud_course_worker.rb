# frozen_string_literal: true

class LernenCloudCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'Lernen.cloud'
  MOOC_PROVIDER_API_LINK = 'https://lernen.cloud/api/v2/courses'
  COURSE_LINK_BODY = 'https://lernen.cloud/courses/'
end
