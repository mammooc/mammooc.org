# frozen_string_literal: true

class OpenWHOCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'OpenWHO'
  MOOC_PROVIDER_API_LINK = 'https://openwho.org/api/v2/courses'
  COURSE_LINK_BODY = 'https://openwho.org/courses/'
end
