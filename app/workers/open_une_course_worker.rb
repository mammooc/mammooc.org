# encoding: utf-8
# frozen_string_literal: true

class OpenUNECourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openUNE'.freeze
  MOOC_PROVIDER_API_LINK = 'https://openune.cn/api/courses'.freeze
  COURSE_LINK_BODY = 'https://openune.cn/courses/'.freeze
end
