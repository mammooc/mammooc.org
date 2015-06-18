# -*- encoding : utf-8 -*-
class AbstractXikoloConnector < AbstractMoocProviderConnector
  AUTHENTICATE_API = 'authenticate/'
  ENROLLMENTS_API_V1 = 'users/me/enrollments/'
  ENROLLMENTS_API_V2 = 'my_enrollments/'
  COURSES_API = 'courses/'

  private

  def send_connection_request(user, credentials)
    request_parameters = "email=#{credentials[:email]}&password=#{credentials[:password]}"
    authentication_url = self.class::ROOT_API_V2 + AUTHENTICATE_API
    response = RestClient.post(authentication_url, request_parameters, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: 'token=\"78783786789\"')
    json_response = JSON.parse response
    return unless json_response['token'].present?
    connection = mooc_provider_user_connection user
    connection.access_token = json_response['token']
    connection.save!
  end

  def send_enrollment_for_course(user, course)
    token_string = "Legacy-Token token=#{get_access_token user}"
    api_url = self.class::ROOT_API_V1 + ENROLLMENTS_API_V1
    request_parameters = "course_id=#{course.provider_course_id}"
    RestClient.post(api_url, request_parameters, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string)
  end

  def send_unenrollment_for_course(user, course)
    token_string = "Legacy-Token token=#{get_access_token user}"
    api_url = self.class::ROOT_API_V1 + ENROLLMENTS_API_V1 + course.provider_course_id
    RestClient.delete(api_url, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string)
  end

  def get_enrollments_for_user(user)
    token_string = "Legacy-Token token=#{get_access_token user}"
    api_url = self.class::ROOT_API_V2 + ENROLLMENTS_API_V2
    # response = RestClient.get(api_url, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string)
    # JSON.parse response
    response = '{
  "enrollments": [
    {
      "id": "21129bb5-f00e-40e4-9e66-a2c45a2e4962",
      "role": "student",
      "course_id": "c1556425-5449-4b05-97b3-42b38a39f6c5",
      "proctored": false,
      "points": {
        "achieved": 0.0,
        "maximal": 0.0,
        "percentage": null
      },
      "certificates": {
        "confirmation_of_participation": null,
        "record_of_achievement": null,
        "certificate": null
      },
      "completed": true,
      "quantile": null
    },
    {
      "id": "643c811b-e30f-444b-9ce3-6de39d3e8d1a",
      "role": "student",
      "course_id": "00000001-3300-4444-9999-000000000004",
      "proctored": false,
      "points": {
        "achieved": 0.0,
        "maximal": 0.0,
        "percentage": null
      },
      "certificates": {
        "confirmation_of_participation": null,
        "record_of_achievement": null,
        "certificate": null
      },
      "completed": false,
      "quantile": null
    },
    {
      "id": "77ac6f41-7d54-481f-9fbd-b85dfe38607b",
      "role": "teacher",
      "course_id": "00000001-3300-4444-9999-000000000002",
      "proctored": false,
      "points": {
        "achieved": 0.0,
        "maximal": 0.0,
        "percentage": null
      },
      "certificates": {
        "confirmation_of_participation": null,
        "record_of_achievement": null,
        "certificate": null
      },
      "completed": false,
      "quantile": null
    },
    {
      "id": "d373fa42-cb23-4e28-af6c-c3cd6899c2e1",
      "role": "teacher",
      "course_id": "00000001-3300-4444-9999-000000000001",
      "proctored": false,
      "points": {
        "achieved": 0.0,
        "maximal": 0.0,
        "percentage": null
      },
      "certificates": {
        "confirmation_of_participation": null,
        "record_of_achievement": null,
        "certificate": null
      },
      "completed": false,
      "quantile": null
    }
  ]
}'
    JSON.parse response
  end

  def handle_enrollments_response(response_data, user)
    enrollments_update_map = create_enrollments_update_map mooc_provider, user
    completions_update_map = create_completions_update_map mooc_provider, user

    response_data['enrollments'].each do |course_element|
      course_id = Course.get_course_id_by_mooc_provider_id_and_provider_course_id mooc_provider, course_element['course_id']
      next unless course_id.present?
      course = Course.find(course_id)
      enrolled_course = user.courses.find_by(id: course_id)
      enrolled_course.nil? ? user.courses << course : enrollments_update_map[enrolled_course.id] = true

      next unless course_element['certificates'].value?(true) || course_element['completed'] == true
      completion = user.completions.find_by(course_id: course_id)
      if completion.nil?
        completion = Completion.new
      else
        completions_update_map[completion.id] = true
      end
      completion.quantile = course_element['quantile']
      completion.points_achieved = course_element['points']['achieved']
      completion.user = user
      completion.course = course
      completion.provider_percentage = course_element['points']['percentage']
      completion.save!
      #           course_element['certificates'].each do |key, value|
      #             next unless value
      #             Certificate.create!(type: key, completion: completion)
      #           end
    end
    evaluate_enrollments_update_map enrollments_update_map, user
    evaluate_completions_update_map completions_update_map, user
  end
end
