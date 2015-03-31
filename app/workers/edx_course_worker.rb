class EdxCourseWorker < AbstractCourseWorker

  MOOC_PROVIDER_NAME = 'edX'
  MOOC_PROVIDER_API_LINK = 'http://pipes.yahoo.com/pipes/pipe.run?_id=74859f52b084a75005251ae7a119f371&_render=json'
  # COURSE_LINK_BODY = ''

  def mooc_provider
    MoocProvider.find_by_name(self.class::MOOC_PROVIDER_NAME)
  end

  def get_course_data
    response = RestClient.get(self.class::MOOC_PROVIDER_API_LINK)
    JSON.parse response
  end

  def handle_response_data response_data
    update_map = create_update_map mooc_provider
    # puts response_data['value']['items']
    response_data['value']['items'].each { |course_element|
      # puts course_element['title']
      course = Course.find_by(:provider_course_id => course_element['id'], :mooc_provider_id => mooc_provider.id)
      if course.nil?
        course = Course.new
      else
        update_map[course.id] = true
      end

      course.name = course_element['title']
      course.provider_course_id = course_element['course:id']
      course.mooc_provider_id = mooc_provider.id
      course.url = course_element['link']
    # #   course.language = course_element['language']
      course.imageId = course_element['course:image-thumbnail']
      if course_element['course:start']
        course.start_date = course_element['course:start']
      else
        puts 'EMPTY START DATE'
      end
      if course_element['course:end']
        course.end_date = course_element['course:end']
      else
        puts course_element['title']
      end
      course.abstract = course_element['course:subtitle']
      course.description = course_element['description']
    #   # if !course_element['course:staff'].empty?
    #     course.course_instructors = [course_element['course:staff']]
    #   # end
    # #   course.open_for_registration = !course_element['locked']
    # #
    #   course.requirements = [course_element['course:prerequisites']]
    #   course.categories = [course_element['course:subject']]
    #
      # course.save
    }
    evaluate_update_map update_map
  end

end
