class AbstractUserWorker
  include Sidekiq::Worker
  require 'rest_client'

  def perform users
    if users.blank?
      load_users
    else
      load_specified_users users
    end
  end

  def load_users
    begin
      response_data = get_user_data
    rescue SocketError, RestClient::ResourceNotFound => e
      logger.error e.class.to_s + ": " + e.message
    else
      handle_response_data response_data
    end
  end

  def load_specified_users user
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

  def evaluate_enrollments_update_map update_map
    update_map.each { |course_id,updated|
      course = Course.find(course_id)
      if !updated && course.exit
        course.destroy
      end
    }
  end
end
