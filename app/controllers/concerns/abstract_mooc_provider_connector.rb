require 'rest_client'

class AbstractMoocProviderConnector

  def initialize_connection user, arguments
    raise NotImplementedError
  end

  def load_user_data users
    if users.blank?
      User.find_each do |user|
        if has_connection_to_mooc_provider user
          fetch_user_data user
        end
      end
    else
      users.each do |user|
        if has_connection_to_mooc_provider user
          fetch_user_data user
        end
      end
    end
  end

  private

  def mooc_provider
    MoocProvider.find_by_name(self.class::NAME)
  end

  def has_connection_to_mooc_provider user
    user.mooc_providers.where(id: mooc_provider).present?
  end

  def fetch_user_data user
    begin
      response_data = get_enrollments_for_user user
    rescue SocketError, RestClient::ResourceNotFound, RestClient::SSLCertificateNotVerified => e
      Rails.logger.error e.class.to_s + ": " + e.message
    else
      handle_enrollments_response response_data, user
    end
  end

  def get_enrollments_for_user user
    raise NotImplementedError
  end

  def handle_enrollments_response response_data, user
    raise NotImplementedError
  end

  def create_enrollments_update_map mooc_provider, user
    update_map = Hash.new
    user.courses.where(mooc_provider_id: mooc_provider.id).each do |course|
      update_map.store(course.id, false)
    end
    update_map
  end

  def evaluate_enrollments_update_map update_map, user
    update_map.each do |course_id,updated|
      unless updated
        user.courses.destroy(course_id)
      end
    end
  end

end
