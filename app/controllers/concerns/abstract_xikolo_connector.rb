# frozen_string_literal: true

class AbstractXikoloConnector < AbstractMoocProviderConnector
  AUTHENTICATE_API = 'authenticate/'
  ENROLLMENTS_API = 'users/me/enrollments/'
  DATES_API = 'course-dates/'
  COURSES_API = 'courses/'
  XIKOLO_API_VERSION = '2.0'

  private

  def send_connection_request(user, credentials)
    request_parameters = "email=#{credentials[:email]}&password=#{credentials[:password]}"
    authentication_url = self.class::ROOT_API + AUTHENTICATE_API
    response = RestClient.post(authentication_url, request_parameters, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: 'token=\"78783786789\"')
    json_response = JSON.parse response
    return if json_response['token'].blank?
    connection = mooc_provider_user_connection user
    connection.access_token = json_response['token']
    connection.save!
  end

  def send_enrollment_for_course(user, course)
    token_string = "Token token=#{get_access_token user}"
    api_url = self.class::ROOT_API + ENROLLMENTS_API
    request_parameters = "course_id=#{course.provider_course_id}"
    RestClient.post(api_url, request_parameters, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string)
  end

  def send_unenrollment_for_course(user, course)
    token_string = "Token token=#{get_access_token user}"
    api_url = self.class::ROOT_API + ENROLLMENTS_API + course.provider_course_id
    RestClient.delete(api_url, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string)
  end

  def get_enrollments_for_user(user)
    token_string = "Token token=#{get_access_token user}"
    api_url = self.class::ROOT_API + ENROLLMENTS_API
    response = RestClient.get(api_url, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string)
    JSON.parse response
  end

  def handle_enrollments_response(response_data, user)
    update_map = create_enrollments_update_map mooc_provider, user

    response_data.each do |course_element|
      course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, course_element['course_id'])
      if course.present?
        enrolled_course = user.courses.find_by(id: course.id)
        enrolled_course.nil? ? user.courses << course : update_map[enrolled_course.id] = true
      end
    end
    evaluate_enrollments_update_map update_map, user
  end

  def get_dates_for_user(user)
    token_string = "Legacy-Token token=#{get_access_token user}"
    accept_header = "application/vnd.api+json; xikolo-version=#{XIKOLO_API_VERSION}"
    api_url = self.class::ROOT_API_V2 + DATES_API
    response = RestClient.get(api_url, accept: accept_header, authorization: token_string)
    if response.headers[:x_api_version_expiration_date].present?
      api_expiration_date = response.headers[:x_api_version_expiration_date]
      AdminMailer.xikolo_api_expiration(Settings.admin_email, self.class.name, api_url, api_expiration_date, Settings.root_url).deliver_later
    end

    if response.present?
      JSON::Api::Vanilla.parse response
    else
      []
    end
  end

  def handle_dates_response(response_data, user)
    update_map = create_update_map_for_user_dates user, mooc_provider
    date_list = response_data.keys
    course_list = response_data.rel_links.values

    date_list.zip(course_list).each do |date, related_course|
      external_date_id = date.first.id
      date = date.last
      related_course = File.basename(related_course['related'])

      course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, related_course)
      user_date = UserDate.find_by(user: user, course: course, ressource_id_from_provider: external_date_id, kind: date['type'])
      if user_date.present?
        update_map[user_date.id] = true
        update_existing_entry user_date, date
      else
        create_new_entry user, date, related_course, external_date_id
      end
    end
    change_existing_no_longer_relevant_entries update_map
  end

  def create_new_entry(user, date, related_course, external_date_id)
    user_date = UserDate.new
    user_date.user = user
    user_date.course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, related_course)
    user_date.date = date['date']
    user_date.title = date['title']
    user_date.kind = date['type']
    user_date.relevant = true
    user_date.ressource_id_from_provider = external_date_id
    user_date.save
  end

  def update_existing_entry(user_date, response_date)
    if user_date.date != response_date['date']
      user_date.date = response_date['date']
    end
    if user_date.title != response_date['title']
      user_date.title = response_date['title']
    end
    if user_date.kind != response_date['type']
      user_date.kind = response_date['type']
    end
    user_date.save
  end

  def change_existing_no_longer_relevant_entries(update_map)
    update_map.each do |user_date_id, updated|
      next if updated
      user_date = UserDate.find(user_date_id)
      user_date.relevant = false
      user_date.save
    end
  end
end
