# frozen_string_literal: true

class OpenSAPChinaCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openSAP.cn'
  MOOC_PROVIDER_API_LINK = 'https://open.sap.cn/api/courses'
  COURSE_LINK_BODY = 'https://open.sap.cn/courses/'
end
