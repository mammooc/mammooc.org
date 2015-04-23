class AbstractUserWorker
  include Sidekiq::Worker
  require 'rest_client'

  # users is Array of String
  def perform user_ids

    if user_ids.blank?
      User.find_each do |user|
        if has_connection_to_mooc_provider user
          load_user_data user
        end
      end
    else
      user_ids.each do |user_id|
        user = User.find(user_id)
        if has_connection_to_mooc_provider user
          load_user_data user
        end
      end
    end
  end

  def has_connection_to_mooc_provider user
    return user.mooc_providers.where(id: mooc_provider).present?
  end

  def load_user_data user
    begin
      response_data = get_enrollments_for_user user
    rescue SocketError, RestClient::ResourceNotFound => e
      logger.error e.class.to_s + ": " + e.message
    else
      handle_enrollments_response response_data, user
    end
  end

  def mooc_provider
    raise NotImplementedError
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
    return update_map
  end

  def evaluate_enrollments_update_map update_map, user
    update_map.each do |course_id,updated|
      if !updated
        user.courses.destroy(course_id)
      end
    end
  end
end
