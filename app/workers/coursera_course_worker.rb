class CourseraCourseWorker < AbstractCourseWorker

  MOOC_PROVIDER_NAME = 'coursera'
  MOOC_PROVIDER_COURSE_API_LINK = 'https://api.coursera.org/api/catalog.v1/courses'
  MOOC_PROVIDER_COURSE_FIELDS = '?fields=language,subtitleLanguagesCsv,shortDescription,photo,aboutTheCourse,video,targetAudience,instructor,estimatedClassWorkload,recommendedBackground'
  MOOC_PROVIDER_SESSIONS_API_LINK = 'https://api.coursera.org/api/catalog.v1/sessions'
  MOOC_PROVIDER_SESSIONS_FIELDS = '?fields=courseId,startDay,startMonth,startYear,durationString,active,eligibleForCertificates,eligibleForSignatureTrack,signatureTrackPrice,signatureTrackRegularPrice'
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
    course_data = RestClient.get(MOOC_PROVIDER_COURSE_API_LINK + MOOC_PROVIDER_COURSE_FIELDS)
    parsed_course_data = JSON.parse course_data

    update_map = create_update_map mooc_provider
    iteration_hash = Hash.new

    response_data["elements"].each { |session_element|
      course = Course.find_by(:provider_course_id => session_element["courseId"].to_s + '|' + session_element["id"].to_s, :mooc_provider_id => mooc_provider.id)
      if course.nil?
        course = Course.new
      else
        update_map[course.id] = true
      end

      #find course corresponding to the session
      corresponding_course = parsed_course_data["elements"].find { |course| course["id"]==session_element["courseId"]}

      course.name = corresponding_course["name"]
      course.provider_course_id = session_element["courseId"].to_s + '|' + session_element["id"].to_s
      course.provider_given_duration = session_element["durationString"]
      course.mooc_provider_id = mooc_provider.id
      course.url = COURSE_LINK_BODY + corresponding_course["shortName"]
      course.language = corresponding_course["language"]
      course.imageId = corresponding_course["photo"]
      course.abstract = corresponding_course["shortDescription"]
      course.course_instructors = corresponding_course["instructor"]
      course.subtitle_languages = corresponding_course["subtitleLanguagesCsv"]
      course.videoId = corresponding_course["video"]
      course.description = corresponding_course["aboutTheCourse"]
      course.workload = corresponding_course["estimatedClassWorkload"]

      course.difficulty = case corresponding_course["targetAudience"]
                            when 0 then TARGET_AUDIENCE_0
                            when 1 then TARGET_AUDIENCE_1
                            when 2 then TARGET_AUDIENCE_2
                          end

      if session_element["startYear"] && session_element["startMonth"] && session_element["startDay"]
        course.start_date = DateTime.new(session_element["startYear"],session_element["startMonth"],session_element["startDay"])
      end

      if corresponding_course["recommendedBackground"].length > 0
        course.requirements = [corresponding_course["recommendedBackground"]]
      else
        course.requirements = nil
      end

      course.has_free_version = true
      course.type_of_achievement = ""
      if session_element["eligibleForCertificates"]
        course.type_of_achievement += "Certificate"
      end
      if session_element["eligibleForSignatureTrack"]
        course.has_paid_version = true
        if course.type_of_achievement.length > 0
          course.type_of_achievement += ", "
        end
        course.type_of_achievement += "Signature Track"
      end

      if session_element["signatureTrackPrice"]
        course.costs = session_element["signatureTrackPrice"]
      else
        course.costs = session_element["signatureTrackRegularPrice"]
      end
      course.price_currency = "$"
      # multiple iterations
      unless iteration_hash[corresponding_course["id"]]
        iteration_hash[corresponding_course["id"]] = Array.new
      end
      course.save
      iteration_hash[corresponding_course["id"]] << course.id
    }
    evaluate_update_map update_map
    # multiple iterations
    evaluate_iteration_hash iteration_hash
  end

end

def evaluate_iteration_hash iteration_hash
  iteration_hash.each do |_, course_id_array|
    #filter out courses without a start data, if there is another iteration that has one
    iterations_deletable = false
    course_id_array.each do |id|
      if Course.find(id).start_date
        iterations_deletable = true
      end
    end
    if iterations_deletable
      course_id_array.each do |id|
        course = Course.find(id)
        unless course.start_date
          course_id_array.delete(id)
          course.destroy
        end
      end
    end
    #sort courses depending on their start date
    course_id_array.sort! do |a,b|
      course1 = Course.find(a)
      course2 = Course.find(b)
      if course1.start_date && course2.start_date
        course1.start_date <=> course2.start_date
      else
        a <=> b
      end
    end
    #link the remaining iterations
    for index in 1 ... course_id_array.size
      course = Course.find(course_id_array[index])
      course.previous_iteration_id = course_id_array[index-1]
      course.save
    end
  end
end
