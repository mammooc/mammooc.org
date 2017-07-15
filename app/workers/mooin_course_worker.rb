# frozen_string_literal: true

class MooinCourseWorker < AbstractJsonApiCourseWorker
  MOOC_PROVIDER_NAME = 'mooin'
  MOOC_PROVIDER_API_LINK = 'https://moodalis.oncampus.de/files/moochub.php'
  COURSE_LINK_BODY = 'https://mooin.oncampus.de/local/ildcourseinfo/index.php?id='
end
