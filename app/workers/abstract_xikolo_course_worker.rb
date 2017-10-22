# frozen_string_literal: true

class AbstractXikoloCourseWorker < AbstractCourseWorker
  MOOC_PROVIDER_NAME = ''
  MOOC_PROVIDER_API_LINK = ''
  COURSE_LINK_BODY = ''
  XIKOLO_API_VERSION = '2.0'

  def mooc_provider
    MoocProvider.find_by(name: self.class::MOOC_PROVIDER_NAME)
  end

  def course_data
    url = self.class::MOOC_PROVIDER_API_LINK
    accept_header = "application/vnd.api+json; xikolo-version=#{XIKOLO_API_VERSION}"
    response = RestClient.get(url, accept: accept_header)
    if response.headers[:x_api_version_expiration_date].present?
      api_expiration_date = response.headers[:x_api_version_expiration_date]
      AdminMailer.xikolo_api_expiration(Settings.admin_email, self.class.name, url, api_expiration_date, Settings.root_url).deliver_later
    end

    if response.present?
      data = []
      JSON::Api::Vanilla.parse(response).links.values.each do |link|
        next if link['self'].blank?
        api_host = URI.parse(url).host
        api_scheme = URI.parse(url).scheme
        course_url = URI::Generic.build(host: api_host, scheme: api_scheme, path: link['self']).to_s
        course_response = RestClient.get(course_url, accept: accept_header)
        data.push(JSON::Api::Vanilla.parse(course_response).data) if course_response.present?
      end
      data
    else
      []
    end
  end

  def handle_response_data(response_data)
    update_map = create_update_map mooc_provider
    confirmation_of_participation = CourseTrackType.find_by(type_of_achievement: 'xikolo_confirmation_of_participation')
    record_of_achievement = CourseTrackType.find_by(type_of_achievement: 'xikolo_record_of_achievement')
    qualified_certificate = CourseTrackType.find_by(type_of_achievement: 'xikolo_qualified_certificate')

    response_data.each do |course_element|
      course = Course.find_by(provider_course_id: course_element.id, mooc_provider_id: mooc_provider.id)
      if course.nil?
        course = Course.new
      else
        update_map[course.id] = true
      end

      course.name = course_element.title.strip
      course.provider_course_id = course_element.id
      course.mooc_provider_id = mooc_provider.id
      course.url = self.class::COURSE_LINK_BODY + course_element.slug
      course.language = course_element.language
      if course_element.image_url.present? && course_element.image_url[/[\?&#]/]
        filename = File.basename(course_element.image_url)[/.*?(?=[\?&#])/]
      elsif course_element.image_url.present?
        filename = File.basename(course_element.image_url)
      end

      if course_element.image_url.present? && course.course_image_file_name != filename
        begin
          course.course_image = Course.process_uri(course_element.image_url)
        rescue OpenURI::HTTPError => e
          Rails.logger.error "Couldn't process course image in course #{course_element.id} for URL #{course_element.image_url}: #{e.message}"
          course.course_image = nil
        end
      end
      course.start_date = course_element.start_at
      course.end_date = course_element.end_at
      course.description = convert_to_absolute_urls(parse_markdown(course_element.description))
      course.abstract = convert_to_absolute_urls(parse_markdown(course_element.abstract))
      if course_element.classifiers['category'].present?
        course.categories = course_element.classifiers['category']
      end
      course.course_instructors = course_element.teachers
      course.open_for_registration = course_element.enrollable

      track = CourseTrack.find_by(course_id: course.id, track_type: confirmation_of_participation)
      if course_element.certificates['confirmation_of_participation'].present? && course_element.certificates['confirmation_of_participation']['available']
        track ||= CourseTrack.create!(track_type: confirmation_of_participation)
        track.costs = 0.0
        track.costs_currency = '€'
        course.tracks.push(track)
      else
        track.delete! if track.present?
      end

      track = CourseTrack.find_by(course_id: course.id, track_type: record_of_achievement)
      if course_element.certificates['record_of_achievement'].present? && course_element.certificates['record_of_achievement']['available']
        track ||= CourseTrack.create!(track_type: record_of_achievement)
        track.costs = 0.0
        track.costs_currency = '€'
        course.tracks.push(track)
      else
        track.delete! if track.present?
      end

      track = CourseTrack.find_by(course_id: course.id, track_type: qualified_certificate)
      if course_element.certificates['qualified_certificate'].present? && course_element.certificates['qualified_certificate']['available']
        track ||= CourseTrack.create!(track_type: qualified_certificate)
        track.costs = 60.0
        track.costs_currency = '€'
        track.credit_points = 2
        course.tracks.push(track)
      else
        track.delete! if track.present?
      end
      course.save!
    end
    evaluate_update_map update_map
  end
end
