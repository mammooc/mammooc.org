class AbstractXikoloConnector < AbstractMoocProviderConnector

  AUTHENTICATE_API = 'authenticate/'
  ENROLLMENTS_API = 'users/me/enrollments/'
  COURSES_API = 'courses/'

  private

    def send_connection_request user, credentials
      request_parameters = "email=#{credentials[:email]}&password=#{credentials[:password]}"
      authentication_url = self.class::ROOT_API + AUTHENTICATE_API
      response = RestClient.post(authentication_url, request_parameters, {accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: 'token=\"78783786789\"'})
      json_response = JSON.parse response
      if json_response['token'].present?
        connection = MoocProviderUser.new
        connection.authentication_token = json_response['token']
        connection.user_id = user.id
        connection.mooc_provider_id = mooc_provider.id
        connection.save
      end
    end

    def send_enrollment_for_course user, course
      token_string = "Token token=#{get_authentication_token user}"
      api_url = self.class::ROOT_API + ENROLLMENTS_API
      request_parameters = "course_id=#{course.provider_course_id}"
      RestClient.post(api_url, request_parameters, {accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string})
    end

    def send_unenrollment_for_course user, course
      token_string = "Token token=#{get_authentication_token user}"
      api_url = self.class::ROOT_API + ENROLLMENTS_API + course.provider_course_id
      RestClient.delete(api_url, {accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string})
    end

    def get_enrollments_for_user user
      token_string = "Token token=#{get_authentication_token user}"
      api_url = self.class::ROOT_API + ENROLLMENTS_API
      response = RestClient.get(api_url,{accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string})
      JSON.parse response
    end

    def handle_enrollments_response response_data, user
      update_map = create_enrollments_update_map mooc_provider, user

      response_data.each do |course_element|
        course_id = Course.get_course_id_by_mooc_provider_id_and_provider_course_id mooc_provider.id, course_element['course_id']
        if course_id.present?
          enrolled_course = user.courses.where(:id => course_id).first
          if enrolled_course.nil?
            user.courses << Course.find(course_id)
          else
            update_map[enrolled_course.id] = true
          end
        end
      end
      evaluate_enrollments_update_map update_map, user
    end

end
