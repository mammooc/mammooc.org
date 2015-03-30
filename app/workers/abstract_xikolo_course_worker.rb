class AbstractXikoloCourseWorker < AbstractCourseWorker

  MOOC_PROVIDER_NAME = ''
  MOOC_PROVIDER_API_LINK = ''
  COURSE_LINK_BODY = ''

  def mooc_provider
    MoocProvider.find_by_name(self.class::MOOC_PROVIDER_NAME)
  end

  def get_course_data
    response = RestClient.get(self.class::MOOC_PROVIDER_API_LINK,{:accept => 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', :authorization => 'token=\"78783786789\"'})
    JSON.parse response
  end

  def handle_response_data response_data
    update_map = create_update_map mooc_provider

    response_data.each { |course_element|
      course = Course.find_by(:provider_course_id => course_element['id'], :mooc_provider_id => mooc_provider.id)
      if course.nil?
        course = Course.new
      else
        update_map[course.id] = true
      end

      course.name = course_element['name']
      course.provider_course_id = course_element['id']
      course.mooc_provider_id = mooc_provider.id
      course.url = self.class::COURSE_LINK_BODY + course_element['course_code']
      course.language = course_element['language']
      course.imageId = course_element['visual_url']
      course.start_date = course_element['available_from']
      course.end_date = course_element['available_to']
      course.description = course_element['description']
      if !course_element['lecturer'].empty?
        course.course_instructors = [course_element['lecturer']]
      end
      course.open_for_registration = !course_element['locked']

      course.save
    }
    evaluate_update_map update_map
  end

end
