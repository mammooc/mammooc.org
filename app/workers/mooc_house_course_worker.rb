# encoding: utf-8
# frozen_string_literal: true

class MoocHouseCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'mooc.house'.freeze
  MOOC_PROVIDER_API_LINK = 'https://mooc.house/api/courses'.freeze
  COURSE_LINK_BODY = 'https://mooc.house/courses/'.freeze
end
