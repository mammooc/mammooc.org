class AbstractUserWorker
  include Sidekiq::Worker
  require 'rest_client'

  # users is Array of String
  def perform user_ids

    if user_ids.blank?
      Users.find_each { |user|
        load_user_data user
      }
    else
      user_ids.each { |user_id|
        load_user_data User.find(user_id)
      }
    end
  end

  def load_user_data user
    begin
      response_data = get_enrollments_for_specified_user user
    rescue SocketError, RestClient::ResourceNotFound => e
      logger.error e.class.to_s + ": " + e.message
    else
      handle_enrollments_response response_data, user
    end
  end

  def mooc_provider
    raise NotImplementedError
  end

  def get_enrollments_for_specified_user user
    raise NotImplementedError
  end

  def handle_enrollments_response response_data, user
    raise NotImplementedError
  end

  def create_enrollments_update_map mooc_provider, user
    update_map = Hash.new
    user.courses.where(:mooc_provider_id => mooc_provider.id).each { |course|
      update_map.store(course.id, false)
    }
    return update_map
  end

  def evaluate_enrollments_update_map update_map, user
    update_map.each { |course_id,updated|
      if !updated
        user.courses.destroy(course_id)
      end
    }
  end
end
