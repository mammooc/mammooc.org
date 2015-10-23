# -*- encoding : utf-8 -*-
require 'rest_client'
require 'oauth2'

class AbstractMoocProviderConnector
  def initialize_connection(user, credentials)
    send_connection_request user, credentials
  rescue RestClient::InternalServerError, RestClient::Unauthorized, RestClient::BadRequest => e
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
      result = true
      users.each do |user|
        result &= fetch_user_data user if connection_to_mooc_provider? user
      end
      return result
    end
  end

  def load_dates_for_user(user)
    result = fetch_dates_for_user user if connection_to_mooc_provider? user
    return result
  end


  def connection_to_mooc_provider?(user)
    user.mooc_providers.where(id: mooc_provider).present?
  end

  def oauth_link(_destination, _csrf_token)
    raise NotImplementedError
  end

  def destroy_connection(user)
    return false unless connection_to_mooc_provider? user
    MoocProviderUser.find_by(user: user, mooc_provider: mooc_provider).destroy
    true
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
    return false
  rescue RestClient::Unauthorized => e
    # This would be the case, when the user's authorization token is invalid
    Rails.logger.error "#{e.class}: #{e.message}"
    return false
  else
    handle_enrollments_response response_data, user
    return true
  end

  def fetch_dates_for_user(user)
    response_data = get_dates_for_user user
  rescue SocketError, RestClient::ResourceNotFound, RestClient::SSLCertificateNotVerified => e
    Rails.logger.error "#{e.class}: #{e.message}"
    return false
  rescue RestClient::Unauthorized => e
    # This would be the case, when the user's authorization token is invalid
    Rails.logger.error "#{e.class}: #{e.message}"
    return false
  else
    handle_dates_response response_data, user
    return true
  end

  def get_access_token(user)
    connection = MoocProviderUser.find_by(user_id: user, mooc_provider_id: mooc_provider)
    return unless connection.present?
    if connection.mooc_provider.api_support_state == 'naive'
      connection.access_token
    elsif connection.mooc_provider.api_support_state == 'oauth'
      if connection.access_token_valid_until > Time.zone.now
        connection.access_token
      else
        refresh_access_token(user) if connection.refresh_token.present?
        return nil
      end
    else
      return nil
    end
  end

  def refresh_access_token(_user)
    raise NotImplementedError
  end

  def mooc_provider_user_connection(user)
    if connection_to_mooc_provider? user
      connection = MoocProviderUser.find_by(user_id: user, mooc_provider_id: mooc_provider)
    else
      connection = MoocProviderUser.new
      connection.user_id = user.id
      connection.mooc_provider_id = mooc_provider.id
    end
    connection
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

  def get_dates_for_user(_user)
    raise NotImplementedError
  end

  def handle_dates_response(_response_data, _user)
    raise NotImplementedError
  end

  def create_update_map_for_user_dates(user, mooc_provider)
    update_map = {}
    UserDate.where(user: user, mooc_provider: mooc_provider).each do |existing_date|
      update_map.store(existing_date.id, false)
    end
    update_map
  end

end
