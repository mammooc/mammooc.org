# encoding: utf-8
# frozen_string_literal: true

class MoocHouseCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'mooc.house'
  MOOC_PROVIDER_API_LINK = 'https://mooc.house/api/courses'
  COURSE_LINK_BODY = 'https://mooc.house/courses/'
end
