class AbstractCourseWorker
  include Sidekiq::Worker
  require 'rest_client'

  def perform
    load_courses
  end

  def load_courses
    begin
      response_data = get_course_data
    rescue SocketError, RestClient::ResourceNotFound, RestClient::SSLCertificateNotVerified => e
      Rails.logger.error "#{e.class.to_s}: #{e.message}"
    else
      handle_response_data response_data
    end
  end

  def mooc_provider
    raise NotImplementedError
  end

  def get_course_data
    raise NotImplementedError
  end

  def handle_response_data response_data
    raise NotImplementedError
  end

  def create_update_map mooc_provider
    update_map = Hash.new
    Course.where(:mooc_provider_id => mooc_provider.id).each do |course|
      update_map.store(course.id, false)
    end
    return update_map
  end

  def evaluate_update_map update_map
    update_map.each do |course_id,updated|
      if !updated
        Course.find(course_id).destroy
      end
    end
  end

end
