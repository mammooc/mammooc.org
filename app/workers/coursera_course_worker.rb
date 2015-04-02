class CourseraCourseWorker < AbstractCourseWorker

  MOOC_PROVIDER_NAME = 'coursera'
  MOOC_PROVIDER_COURSE_API_LINK = 'https://api.coursera.org/api/catalog.v1/courses'
  MOOC_PROVIDER_COURSE_FIELDS = '?fields=language,subtitleLanguagesCsv,shortDescription,photo,aboutTheCourse,video,targetAudience,instructor,estimatedClassWorkload,recommendedBackground'
  MOOC_PROVIDER_INCLUDES = '?includes=categories,universities,instructors'
  MOOC_PROVIDER_SESSIONS_API_LINK = 'https://api.coursera.org/api/catalog.v1/sessions'
  MOOC_PROVIDER_SESSIONS_FIELDS = '?fields=courseId,startDay,startMonth,startYear,durationString,active'
  MOOC_PROVIDER_CATEGORIES_INCLUDE_FIELDS = 'categories.fields(name)'
  COURSE_LINK_BODY = 'https://www.coursera.org/course/'
  TARGET_AUDIENCE_0 = 'Basic Undergraduates'
  TARGET_AUDIENCE_1 = 'Advanced undergraduates or beginning graduates'
  TARGET_AUDIENCE_2 = 'Advanced graduates'

  def mooc_provider
    MoocProvider.find_by_name(MOOC_PROVIDER_NAME)
  end

  def get_course_data
    response = RestClient.get(MOOC_PROVIDER_SESSIONS_API_LINK + MOOC_PROVIDER_SESSIONS_FIELDS)
    JSON.parse response
  end

  def handle_response_data response_data
    course_data = RestClient.get(MOOC_PROVIDER_COURSE_API_LINK + MOOC_PROVIDER_COURSE_FIELDS + MOOC_PROVIDER_CATEGORIES_INCLUDE_FIELDS + MOOC_PROVIDER_INCLUDES)
    xyz = JSON.parse course_data

    update_map = create_update_map mooc_provider

    response_data["elements"].each { |course_element|
     # includes not yet working as they should
      course = Course.find_by(:provider_course_id => course_element["courseId"].to_s + '|' + course_element["id"].to_s, :mooc_provider_id => mooc_provider.id)
      if course.nil?
        course = Course.new
      else
        update_map[course.id] = true
      end

      #find corresponding course
      corresponding_course = xyz["elements"].find { |h1| h1["id"]==course_element["courseId"]}
      course.name = corresponding_course["name"]
      #puts corresponding_course["categories"]["name"]

      course.provider_course_id = course_element["courseId"].to_s + '|' + course_element["id"].to_s
      course.provider_given_duration = course_element["durationString"]
      if course_element["startYear"] && course_element["startMonth"] && course_element["startDay"]
        course.start_date = DateTime.new(course_element["startYear"],course_element["startMonth"],course_element["startDay"])
      end
      course.mooc_provider_id = mooc_provider.id
      course.url = COURSE_LINK_BODY + corresponding_course["shortName"]
      course.language = corresponding_course["language"]
      course.imageId = corresponding_course["photo"]
      course.abstract = corresponding_course["shortDescription"]
      course.course_instructors = corresponding_course["instructor"]
      course.open_for_registration = !course_element["active"]
      course.difficulty = case corresponding_course["targetAudience"]
                            when 0 then TARGET_AUDIENCE_0
                            when 1 then TARGET_AUDIENCE_1
                            when 2 then TARGET_AUDIENCE_2
                          end
      # multiple iterations
      course.subtitle_languages = corresponding_course["subtitleLanguagesCsv"]
      course.videoId = corresponding_course["video"]
      course.description = corresponding_course["aboutTheCourse"]
      course.workload = corresponding_course["estimatedClassWorkload"]
      course.requirements = [corresponding_course["recommendedBackground"]]

      course.save
    }
    evaluate_update_map update_map
  end

end
