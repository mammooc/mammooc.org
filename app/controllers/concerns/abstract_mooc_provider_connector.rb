# -*- encoding : utf-8 -*-
require 'rest_client'

class AbstractMoocProviderConnector
  def initialize_connection(user, credentials)
    send_connection_request user, credentials
  rescue RestClient::InternalServerError => e
    Rails.logger.error "#{e.class}: #{e.message}"
    return false
  else
    return true
  end

  def enroll_user_for_course(user, course)
    return unless connection_to_mooc_provider? user
    begin
      send_enrollment_for_course user, course
    rescue RestClient::InternalServerError, RestClient::BadGateway,
           RestClient::ResourceNotFound, RestClient::BadRequest => e
      Rails.logger.error "#{e.class}: #{e.message}"
      return false
    rescue RestClient::Unauthorized => e
      # This would be the case, when the user's authorization token is invalid
      Rails.logger.error "#{e.class}: #{e.message}"
      return false
    else
      return true
    end
  end

  def unenroll_user_for_course(user, course)
    return unless connection_to_mooc_provider? user
    begin
      send_unenrollment_for_course user, course
    rescue RestClient::InternalServerError => e
      Rails.logger.error "#{e.class}: #{e.message}"
      return false
    rescue RestClient::Unauthorized => e
      # This would be the case, when the user's authorization token is invalid
      Rails.logger.error "#{e.class}: #{e.message}"
      return false
    else
      return true
    end
  end

  def load_user_data(users = nil)
    if users.blank?
      User.find_each do |user|
        fetch_user_data user if connection_to_mooc_provider? user
      end
    else
      users.each do |user|
        fetch_user_data user if connection_to_mooc_provider? user
      end
    end
  end

  def connection_to_mooc_provider?(user)
    user.mooc_providers.where(id: mooc_provider).present?
  end

  private

  def mooc_provider
    MoocProvider.find_by_name(self.class::NAME)
  end

  def send_connection_request(_user, _credentials)
    raise NotImplementedError
  end

  def send_enrollment_for_course(_user, _course)
    raise NotImplementedError
  end

  def send_unenrollment_for_course(_user, _course)
    raise NotImplementedError
  end

  def fetch_user_data(user)
    response_data = get_enrollments_for_user user
  rescue SocketError, RestClient::ResourceNotFound, RestClient::SSLCertificateNotVerified => e
    Rails.logger.error "#{e.class}: #{e.message}"
  else
    handle_enrollments_response response_data, user
  end

  def get_authentication_token(user)
    connection = MoocProviderUser.find_by(user_id: user, mooc_provider_id: mooc_provider)
    connection.present? ? connection.authentication_token : nil
  end

  def get_enrollments_for_user(_user)
    raise NotImplementedError
  end

  def handle_enrollments_response(_response_data, _user)
    raise NotImplementedError
  end

  def create_enrollments_update_map(mooc_provider, user)
    update_map = {}
    user.courses.where(mooc_provider_id: mooc_provider.id).each do |course|
      update_map.store(course.id, false)
    end
    update_map
  end

  def evaluate_enrollments_update_map(update_map, user)
    update_map.each do |course_id, updated|
      user.courses.destroy(course_id) unless updated
    end
  end
end
