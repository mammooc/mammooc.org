# encoding: utf-8
# frozen_string_literal: true

class CourseraConnector < AbstractMoocProviderConnector
  NAME = 'coursera'
  COURSE_LINK = 'https://www.coursera.org/course/'

  OAUTH_API = 'https://accounts.coursera.org/oauth2/v1/'
  AUTHENTICATE_API = 'auth'
  TOKEN_API = 'token'
  OAUTH_CLIENT_ID = ENV['COURSERA_CLIENT_ID']
  OAUTH_SECRET_KEY = ENV['COURSERA_SECRET_KEY']
  REDIRECT_URI = "#{Settings.root_url}/oauth/callback"

  ROOT_API = 'https://api.coursera.org/api/'
  ENROLLMENTS_API = 'users/v1/me/enrollments'
  COURSES_API = 'catalog.v1/courses'

  def oauth_link(destination, csrf_token)
    response_type = 'code'
    scope = 'view_profile'
    state = "coursera~#{destination}~#{csrf_token}"
    oauth_client.auth_code.authorize_url(response_type: response_type, scope: scope, state: state, redirect_uri: REDIRECT_URI)
  end

  private

  def oauth_client
    OAuth2::Client.new(OAUTH_CLIENT_ID, OAUTH_SECRET_KEY, authorize_url: OAUTH_API + AUTHENTICATE_API, token_url: OAUTH_API + TOKEN_API)
  end

  def send_connection_request(user, credentials)
    code = credentials[:code]
    response = oauth_client.auth_code.get_token(code, redirect_uri: REDIRECT_URI, grant_type: 'authorization_code')
    return unless response.token.present?
    connection = mooc_provider_user_connection user
    connection.access_token = response.token
    connection.access_token_valid_until = Time.zone.at(response.expires_at)
    connection.save!
  end

  def get_enrollments_for_user(user)
    token_string = "Bearer #{get_access_token user}"
    api_url = ROOT_API + ENROLLMENTS_API
    response = RestClient.get(api_url, authorization: token_string)
    JSON.parse response
  end

  def handle_enrollments_response(response_data, user)
    update_map = create_enrollments_update_map mooc_provider, user

    response_data['enrollments'].each do |course_element|
      provider_course_id = "#{course_element['courseId']}|#{course_element['sessionId']}"
      course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, provider_course_id)
      if course.present?
        enrolled_course = user.courses.find_by(id: course.id)
        enrolled_course.nil? ? user.courses << course : update_map[enrolled_course.id] = true
      end
    end
    evaluate_enrollments_update_map update_map, user
  end
end
