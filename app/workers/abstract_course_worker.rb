# frozen_string_literal: true

class AbstractCourseWorker
  include Sidekiq::Worker
  require 'rest_client'

  def perform
    load_courses
  end

  def load_courses
    response_data = course_data
  rescue SocketError, Errno::ECONNREFUSED, RestClient::ResourceNotFound, RestClient::SSLCertificateNotVerified => e
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

  def convert_to_absolute_urls(html)
    document = Nokogiri::HTML.fragment(html)
    tags = {'img' => 'src', 'a' => 'href', 'video' => 'src'}

    document.search(tags.keys.join(',')).each do |node|
      url_attribute = tags[node.name]

      uri_string = node[url_attribute]
      next if uri_string.empty?
      uri = URI.parse(uri_string)
      next if uri.host.present?
      uri.scheme = URI(self.class::COURSE_LINK_BODY).scheme
      uri.host = URI(self.class::COURSE_LINK_BODY).host
      node[url_attribute] = uri.to_s
    end
    document.to_html
  end
end
