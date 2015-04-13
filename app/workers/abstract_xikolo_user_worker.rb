class AbstractXikoloUserWorker < AbstractUserWorker

  MOOC_PROVIDER_NAME = ''
  MOOC_PROVIDER_API_ROOT_LINK = ''
  MOOC_PROVIDER_LIST_ENROLLMENTS_API = 'users/me/enrollments/'

  def mooc_provider
    MoocProvider.find_by_name(self.class::MOOC_PROVIDER_NAME)
  end

  def get_enrollments_for_specified_user user
    authentication_token = MoocProviderUser.where(user_id: user, mooc_provider_id: mooc_provider).first.authentication_token
    token_string = "Token token=#{authentication_token}"
    api_url = self.class::MOOC_PROVIDER_API_ROOT_LINK + self.class::MOOC_PROVIDER_LIST_ENROLLMENTS_API
    response = RestClient.get(api_url,{:accept => 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', :authorization => token_string})
    JSON.parse response
  end

  def handle_enrollments_response response_data, user
    update_map = create_enrollments_update_map mooc_provider, user

    response_data.each { |course_element|
      course_id = Course.get_course_id_by_mooc_provider_id_and_provider_course_id mooc_provider.id, course_element['course_id']
      enrolled_course = user.courses.where(:id => course_id).first
      if enrolled_course.nil?
        user.courses << Course.find(course_id)
      else
        update_map[enrolled_course.id] = true
      end
    }
    evaluate_enrollments_update_map update_map, user
  end

end
