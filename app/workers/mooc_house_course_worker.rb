# -*- encoding : utf-8 -*-
class MoocHouseCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'mooc.house'
  MOOC_PROVIDER_API_LINK = 'https://mooc.house/api/v2/'
  COURSE_LINK_BODY = 'https://mooc.house/courses/'
end
