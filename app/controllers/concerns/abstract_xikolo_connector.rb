class AbstractXikoloConnector < AbstractMoocProviderConnector

  AUTHENTICATE_API = 'authenticate/'
  ENROLLMENTS_API = 'users/me/enrollments/'
  COURSES_API = 'courses/'


  def initialize_connection user, arguments
    request_parameters = "email=#{arguments[:email]}&password=#{arguments[:password]}"
    authentication_url = self.class::ROOT_API + AUTHENTICATE_API
    response = RestClient.post(authentication_url, request_parameters, {accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: 'token=\"78783786789\"'})
    json_response = JSON.parse response

    connection = MoocProviderUser.new
    connection.authentication_token = json_response['token']
    connection.user_id = user.id
    connection.mooc_provider_id = mooc_provider.id
    connection.save
  end

  def enroll_user_for_course user, course_id
    token_string = "Token token=#{get_authentication_token user}"
    api_url = self.class::ROOT_API + ENROLLMENTS_API
    request_parameters = "course_id=#{Course.get_provider_course_id_by_course_id course_id}"
    begin
      RestClient.post(api_url, request_parameters, {accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string})
    rescue RestClient::InternalServerError => e
      Rails.logger.error e.class.to_s + ": " + e.message
      return false
    else
      return true
    end
  end

  def unenroll_user_for_course user, course_id
    token_string = "Token token=#{get_authentication_token user}"
    api_url = self.class::ROOT_API + ENROLLMENTS_API + "#{Course.get_provider_course_id_by_course_id course_id}"
    begin
      RestClient.delete(api_url, {accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string})
    rescue RestClient::InternalServerError => e
      Rails.logger.error e.class.to_s + ": " + e.message
      return false
    else
      return true
    end
  end


  private

    def get_authentication_token user
      MoocProviderUser.where(user_id: user, mooc_provider_id: mooc_provider).first.authentication_token
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
