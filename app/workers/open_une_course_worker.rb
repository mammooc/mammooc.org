# frozen_string_literal: true

class OpenUNECourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openUNE.cn'
  MOOC_PROVIDER_API_LINK = 'https://openune.cn/api/courses'
  COURSE_LINK_BODY = 'https://openune.cn/courses/'
end
