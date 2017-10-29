# frozen_string_literal: true

class AbstractXikoloConnector < AbstractMoocProviderConnector
  AUTHENTICATE_API = 'authenticate/'
  ENROLLMENTS_API = 'enrollments/'
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
    api_url = self.class::ROOT_API_V2 + ENROLLMENTS_API
    payload = "{
         \"data\":{
            \"type\":\"enrollments\",
            \"attributes\":{ },
            \"relationships\":{
               \"course\":{
                  \"data\":{
                     \"type\":\"courses\",
                     \"id\":\"#{course.provider_course_id}\"
                  }
               }
            }
         }
      }"
    response = RestClient.post(api_url, payload, accept: accept_header, content_type: accept_header, authorization: token_string(user))
    handle_api_expiration_header response
  end

  def send_unenrollment_for_course(user, course)
    api_url = self.class::ROOT_API_V2 + ENROLLMENTS_API + course.provider_course_id
    response = RestClient.delete(api_url, accept: accept_header, authorization: token_string(user))
    handle_api_expiration_header response
  end

  def get_enrollments_for_user(user)
    api_url = self.class::ROOT_API_V2 + ENROLLMENTS_API
    response = RestClient.get(api_url, accept: accept_header, authorization: token_string(user))
    handle_api_expiration_header response

    if response.present?
      JSON::Api::Vanilla.parse response
    else
      []
    end
  end

  def handle_enrollments_response(response_data, user)
    update_map = create_enrollments_update_map mooc_provider, user

    if response_data.present?
      enrollment_list = response_data.data
      course_list = response_data.rel_links.values.select {|hash| hash['related'].include? 'courses' }

      enrollment_list.zip(course_list).each do |enrollment, related_course|
        related_course = File.basename(related_course['related'])
        course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, related_course)
        next if course.blank?

        enrolled_course = user.courses.find_by(id: course.id)
        enrolled_course.nil? ? user.courses << course : update_map[enrolled_course.id] = true

        course.points_maximal = enrollment.points['maximal']
        course.save!

        next unless enrollment.completed
        completion = Completion.find_or_create_by(course: course, user: user)
        completion.points_achieved = enrollment.points['achieved']
        completion.provider_percentage = enrollment.points['percentage']
        completion.provider_id = enrollment.id
        completion.save!
        completion.reload

        enrollment.certificates.each do |document_type, achieved|
          next unless achieved
          certificate = Certificate.find_or_initialize_by(completion: completion, document_type: document_type)
          certificate.download_url = mooc_provider.url
          certificate.save!
        end
      end
    end
    evaluate_enrollments_update_map update_map, user
  end

  def get_dates_for_user(user)
    api_url = self.class::ROOT_API_V2 + DATES_API
    response = RestClient.get(api_url, accept: accept_header, authorization: token_string(user))
    handle_api_expiration_header response

    if response.present?
      JSON::Api::Vanilla.parse response
    else
      []
    end
  end

  def handle_dates_response(response_data, user)
    update_map = create_update_map_for_user_dates user, mooc_provider

    if response_data.present?
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

  def accept_header
    "application/vnd.api+json; xikolo-version=#{XIKOLO_API_VERSION}"
  end

  def token_string user
    "Legacy-Token token=#{get_access_token user}"
  end

  def handle_api_expiration_header response
    return if response.headers[:x_api_version_expiration_date].blank?
    api_expiration_date = response.headers[:x_api_version_expiration_date]
    AdminMailer.xikolo_api_expiration(Settings.admin_email, self.class.name, response.request.url, api_expiration_date, Settings.root_url).deliver_later
  end
end
