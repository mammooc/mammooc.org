# encoding: utf-8
# frozen_string_literal: true

class OpenSAPCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openSAP'
  MOOC_PROVIDER_API_LINK = 'https://open.sap.com/api/v2/'
  ROOT_URL = 'https://open.sap.com'
end
