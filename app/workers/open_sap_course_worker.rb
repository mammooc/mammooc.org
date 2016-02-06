# encoding: utf-8
# frozen_string_literal: true

class OpenSAPCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openSAP'.freeze
  MOOC_PROVIDER_API_LINK = 'https://open.sap.com/api/courses'.freeze
  COURSE_LINK_BODY = 'https://open.sap.com/courses/'.freeze
end
