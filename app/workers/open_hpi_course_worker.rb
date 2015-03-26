class OpenHPICourseWorker < AbstractCourseWorker

  MOOC_PROVIDER_NAME = 'openHPI'
  MOOC_PROVIDER_API_LINK = 'https://open.hpi.de/api/courses'
  COURSE_LINK_BODY = 'https://open.hpi.de/courses/'

  def moocProvider
    MoocProvider.find_by_name(MOOC_PROVIDER_NAME)
  end

  def getCourseData
    response = RestClient.get(MOOC_PROVIDER_API_LINK,{:accept => 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', :authorization => 'token=\"78783786789\"'})
    JSON.parse response
  end

  def handleResponseData responseData
    updateMap = createUpdateMap moocProvider

    responseData.each { |courseElement|
      course = Course.find_by(:provider_course_id => courseElement['id'], :mooc_provider_id => moocProvider.id)
      if course.nil?
        course = Course.new
      else
        updateMap[course.id] = true
      end

      course.name = courseElement['name']
      course.provider_course_id = courseElement['id']
      course.mooc_provider_id = moocProvider.id
      course.url = COURSE_LINK_BODY + courseElement['course_code']
      course.language = courseElement['language']
      course.imageId = courseElement['visual_url']
      course.start_date = courseElement['available_from']
      course.end_date = courseElement['available_to']
      course.description = courseElement['description']
      course.course_instructors = [courseElement['lecturer']]
      course.open_for_registration = !courseElement['locked']

      course.save
    }
    evaluateUpdateMap updateMap
  end
end
