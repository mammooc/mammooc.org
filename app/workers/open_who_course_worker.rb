# frozen_string_literal: true

class OpenWHOCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openWHO'
  MOOC_PROVIDER_API_LINK = 'https://openwho.org/api/courses'
  COURSE_LINK_BODY = 'https://openwho.org/courses/'
end
