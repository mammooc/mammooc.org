class AbstractXikoloUserWorker < AbstractUserWorker

  MOOC_PROVIDER_NAME = ''
  MOOC_PROVIDER_API_ROOT_LINK = ''
  MOOC_PROVIDER_LIST_ENROLLMENTS_API = 'users/me/enrollments/'

  def mooc_provider
    MoocProvider.find_by_name(self.class::MOOC_PROVIDER_NAME)
  end

  def get_enrollments_for_specified_user user
    authentication_token = MoocProviderUser.where(user_id: user, mooc_provider_id: mooc_provider).first.authentication_token
    api_url = self.class::MOOC_PROVIDER_API_ROOT_LINK + self.class::MOOC_PROVIDER_LIST_ENROLLMENTS_API
    response = RestClient.get(api_url,{:accept => 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', :authorization => authentication_token})
    JSON.parse response
  end

  def handle_enrollments_response response_data, user
    update_map = create_enrollments_update_map mooc_provider, user

    response_data.each { |course_element|
      course = Course.get_course_id_by_mooc_provider_id_and_provider_course_id mooc_provider.id, course_element['id']
      course_enrollment = user.courses.where(:course_id => course.id)
      if course_enrollment.nil?
        course_enrollment = Course.new
      else
        update_map[course_enrollment.id] = true
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
      course.course_instructors = course_element['lecturer']
      course.open_for_registration = !course_element['locked']
      course.has_free_version = true

      course.save
    }
    evaluate_enrollments_update_map update_map
  end

end
