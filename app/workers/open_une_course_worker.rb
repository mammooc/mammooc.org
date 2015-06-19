# -*- encoding : utf-8 -*-
class OpenUNECourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openUNE'
  MOOC_PROVIDER_API_LINK = 'https://openune.cn/api/v2/courses'
  COURSE_LINK_BODY = 'https://openune.cn/courses/'
end
