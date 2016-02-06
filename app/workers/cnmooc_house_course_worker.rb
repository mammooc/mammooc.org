# encoding: utf-8
# frozen_string_literal: true

class CnmoocHouseCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'cnmooc.house'.freeze
  MOOC_PROVIDER_API_LINK = 'https://cnmooc.house/api/courses'.freeze
  COURSE_LINK_BODY = 'https://cnmooc.house/courses/'.freeze
end
