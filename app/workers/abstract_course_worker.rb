# -*- encoding : utf-8 -*-
class AbstractCourseWorker
  include Sidekiq::Worker
  require 'rest_client'

  def perform
    load_courses
  end

  def load_courses
    response_data = course_data
  rescue SocketError, RestClient::ResourceNotFound, RestClient::SSLCertificateNotVerified => e
    Rails.logger.error "#{e.class}: #{e.message}"
  else
    handle_response_data response_data
  end

  def mooc_provider
    raise NotImplementedError
  end

  def course_data
    raise NotImplementedError
  end

  def handle_response_data(_response_data)
    raise NotImplementedError
  end

  def create_update_map(mooc_provider)
    update_map = {}
    Course.where(mooc_provider_id: mooc_provider.id).each do |course|
      update_map.store(course.id, false)
    end
    update_map
  end

  def evaluate_update_map(update_map)
    update_map.each do |course_id, updated|
      course = Course.find(course_id)
      course.destroy if !updated && course.present?
    end
  end

  def parse_markdown(text)
    redcarpet = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    redcarpet.render(text).html_safe
  end
end
