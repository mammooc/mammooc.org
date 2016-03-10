# encoding: utf-8
# frozen_string_literal: true

class AbstractXikoloConnector < AbstractMoocProviderConnector
  AUTHENTICATE_API = 'authenticate/'
  ENROLLMENTS_API_V1 = 'users/me/enrollments/'
  ENROLLMENTS_API_V2 = 'my_enrollments/'
  DATES_API = 'dates/'
  COURSES_API = 'courses/'

  private

  def send_connection_request(user, credentials)
    request_parameters = "email=#{credentials[:email]}&password=#{credentials[:password]}"
    authentication_url = self.class::ROOT_API_V1 + AUTHENTICATE_API
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
    response = RestClient.get(api_url, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string)
    JSON.parse response
  end

  def handle_enrollments_response(response_data, user)
    enrollments_update_map = create_enrollments_update_map mooc_provider, user
    completions_update_map = create_completions_update_map mooc_provider, user

    response_data['enrollments'].each do |course_element|
      course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, course_element['course_id'])
      next unless course.present?
      enrolled_course = user.courses.find_by(id: course.id)
      enrolled_course.nil? ? user.courses << course : enrollments_update_map[enrolled_course.id] = true

      next unless course_element['certificates'].value?(true) || course_element['completed'] == true
      completion = user.completions.find_by(course_id: course.id)
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

  def get_dates_for_user(user)
    token_string = "Legacy-Token token=#{get_access_token user}"
    api_url = self.class::ROOT_API_V2 + DATES_API
    response = RestClient.get(api_url, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: token_string)
    JSON.parse response
  end

  def handle_dates_response(response_data, user)
    update_map = create_update_map_for_user_dates user, mooc_provider
    response_data['dates'].each do |response_user_date|
      course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, response_user_date['course_id'])
      user_date = UserDate.find_by(user: user, course: course, ressource_id_from_provider: response_user_date['resource_id'], kind: response_user_date['kind'])
      if user_date.present?
        update_map[user_date.id] = true
        update_existing_entry user_date, response_user_date
      else
        create_new_entry user, response_user_date
      end
    end
    change_existing_no_longer_relevant_entries update_map
  end

  def create_new_entry(user, response_user_date)
    user_date = UserDate.new
    user_date.user = user
    user_date.course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, response_user_date['course_id'])
    user_date.date = response_user_date['date']
    user_date.title = response_user_date['title']
    user_date.kind = response_user_date['kind']
    user_date.relevant = true
    user_date.ressource_id_from_provider = response_user_date['resource_id']
    user_date.save
  end

  def update_existing_entry(user_date, response_user_date)
    if user_date.date != response_user_date['date']
      user_date.date = response_user_date['date']
    end
    if user_date.title != response_user_date['title']
      user_date.title = response_user_date['title']
    end
    if user_date.kind != response_user_date['kind']
      user_date.kind = response_user_date['kind']
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
