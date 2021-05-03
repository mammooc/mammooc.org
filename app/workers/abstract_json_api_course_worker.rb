# frozen_string_literal: true

class AbstractJsonApiCourseWorker < AbstractCourseWorker
  MOOC_PROVIDER_NAME = ''
  MOOC_PROVIDER_API_LINK = ''
  COURSE_LINK_BODY = ''

  def mooc_provider
    MoocProvider.find_by(name: self.class::MOOC_PROVIDER_NAME)
  end

  def course_data
    data = []
    url = self.class::MOOC_PROVIDER_API_LINK
    loop do
      response_json = get_page url
      return response_json if response_json.is_a?(Array)

      data += response_json.keys.values
      current_page = response_json.rel_links['self']
      next_page = response_json.rel_links['self']
      url = next_page
      break unless next_page.present? && current_page != next_page
    end
    data
  end

  def get_page(url)
    response = RestClient.get(url, accept: 'application/vnd.api+json')
    return [] if response.blank?

    response = Nokogiri::HTML(response).xpath('//pre/text()').text if response.starts_with? '<pre>'
    response.present? ? JSON::Api::Vanilla.parse(response) : []
  end

  def handle_response_data(response_data)
    update_map = create_update_map mooc_provider
    non_free_track_type = CourseTrackType.find_by(type_of_achievement: "#{mooc_provider.name}_full_certificate")
    free_track_type = CourseTrackType.find_by(type_of_achievement: "#{mooc_provider.name}_certificate")

    response_data.each do |course_element|
      course = Course.find_by(provider_course_id: course_element['courseCode'], mooc_provider_id: mooc_provider.id)
      if course.nil?
        course = Course.new
      else
        update_map[course.id] = true
      end

      course.name = course_element['name'].strip
      course.provider_course_id = course_element['courseCode']
      course.mooc_provider_id = mooc_provider.id
      course.videoId = course_element['video']
      course.language = course_element['languages'].join(',')
      if course_element['image'].present? && course_element['image'][/[\?&#]/]
        filename = File.basename(course_element['image'])[/.*?(?=[\?&#])/]
      elsif course_element['image'].present? && course_element['image']['url'].present?
        filename = File.basename(course_element['image']['url'])
      end

      if course_element['url'].present?
        course.url = course_element['url']
      elsif course_element['courseCode'].present?
        course.url = self.class::COURSE_LINK_BODY + course_element['courseCode']
      elsif course_element['moocProvider'].present? && course_element['moocProvider']['url'].present?
        course.url = course_element['moocProvider']['url']
      end

      if filename.present? && course.course_image_file_name != filename
        begin
          course.course_image = Course.process_uri(course_element['image']['url'])
        rescue OpenURI::HTTPError, Paperclip::Error => e
          Rails.logger.error "Couldn't process course image in course #{course_element.id} for URL #{course_element.image}: #{e.message}"
          course.course_image = nil
        end
      end
      course.start_date = course_element['startDate']
      course.end_date = course_element['endDate']
      course.abstract = course_element['abstract']
      course.description = course_element['description']

      course.course_instructors = ''
      if course_element['instructors'].present?
        course_element['instructors'].each_with_index do |instructor, i|
          course.course_instructors += "#{i.positive? ? ', ' : ''}#{instructor['name']}"
        end
      end

      course.workload = course_element['workload']
      course.provider_given_duration = course_element['duration']

      begin
        course.calculated_duration_in_days = ActiveSupport::Duration.parse(course_element['duration']) / 1.day
      rescue ActiveSupport::Duration::ISO8601Parser::ParsingError => e
        Rails.logger.error "Couldn't process douration in course #{course_element['courseCode']} for duration #{course_element['duration']}: #{e.message}"
        course.calculated_duration_in_days = nil
      end

      track = if course_element['access'].include?('free')
                CourseTrack.find_by(course_id: course.id, track_type: free_track_type) || CourseTrack.create!(track_type: free_track_type, costs: 0.0, costs_currency: "\xe2\x82\xac")
              else
                CourseTrack.find_by(course_id: course.id, track_type: non_free_track_type) || CourseTrack.create!(track_type: non_free_track_type)
              end
      course.tracks.push(track)

      if course_element['partnerInstitute'].present?
        partner = course_element['partnerInstitute'].first
        organisation = Organisation.find_or_create_by(name: partner['name'], url: partner['url'])
        course.organisation = organisation
      end

      course.save!
    end
    evaluate_update_map update_map
  end
end
