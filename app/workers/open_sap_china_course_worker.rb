# encoding: utf-8
# frozen_string_literal: true

class OpenSAPChinaCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openSAP China'.freeze
  MOOC_PROVIDER_API_LINK = 'https://open.sap.cn/api/courses'.freeze
  COURSE_LINK_BODY = 'https://open.sap.cn/courses/'.freeze
end
