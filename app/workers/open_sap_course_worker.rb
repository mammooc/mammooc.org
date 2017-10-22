# frozen_string_literal: true

class OpenSAPCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openSAP'
  MOOC_PROVIDER_API_LINK = 'https://open.sap.com/api/v2/courses'
  COURSE_LINK_BODY = 'https://open.sap.com/courses/'
end
