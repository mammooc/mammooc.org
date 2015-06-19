# -*- encoding : utf-8 -*-
class CnmoocHouseCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'cnmooc.house'
  MOOC_PROVIDER_API_LINK = 'https://cnmooc.house/api/courses'
  COURSE_LINK_BODY = 'https://cnmooc.house/courses/'
end
