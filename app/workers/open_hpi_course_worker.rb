# encoding: utf-8
# frozen_string_literal: true

class OpenHPICourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openHPI'
  MOOC_PROVIDER_API_LINK = 'https://open.hpi.de/api/courses'
  COURSE_LINK_BODY = 'https://open.hpi.de/courses/'
end
