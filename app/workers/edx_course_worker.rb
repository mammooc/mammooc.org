# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

class EdxCourseWorker < AbstractCourseWorker
  MOOC_PROVIDER_NAME = 'edX'
  MOOC_PROVIDER_API_LINK = 'https://www.edx.org/api/v2/report/course-feed/rss'

  def mooc_provider
    MoocProvider.find_by(name: self.class::MOOC_PROVIDER_NAME)
  end

  def course_data
    data = []
    data.push(Nokogiri::XML(OpenURI.open_uri(MOOC_PROVIDER_API_LINK)))
    i = 0
    last_page = data[i].xpath("//channel/atom:link[@rel='last']/@href").text
    next_page = data[i].xpath("//channel/atom:link[@rel='next']/@href").text
    while last_page != next_page
      next_page = data[i].xpath("//channel/atom:link[@rel='next']/@href").text
      i += 1
      data.push(Nokogiri::XML(OpenURI.open_uri(next_page)))
    end
    data
  end

  def handle_response_data(response_data)
    update_map = create_update_map mooc_provider

    free_track_type = CourseTrackType.find_by(type_of_achievement: 'nothing')
    certificate_track_type = CourseTrackType.find_by(type_of_achievement: 'edx_verified_certificate')
    xseries_track_type = CourseTrackType.find_by(type_of_achievement: 'edx_xseries_verified_certificate')
    profed_track_type = CourseTrackType.find_by(type_of_achievement: 'edx_profed_certificate')

    response_data.each do |xml_doc|
      language = xml_doc.xpath('//channel/language').text
      xml_doc.xpath('//channel/item').each do |course_element|
        Raven.extra_context(course_element: course_element)
        course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, course_element.xpath('course:id').text)
        if course.nil?
          course = Course.new
        else
          update_map[course.id] = true
        end

        course.name = course_element.xpath('title').text.strip
        course.provider_course_id = course_element.xpath('course:id').text
        course.mooc_provider_id = mooc_provider.id
        course.url = course_element.xpath('link').text
        course.language = language

        course_thumbnail = course_element.xpath('course:image-thumbnail')
        if course_thumbnail.present? && course_thumbnail.text[/[\?&#]/]
          filename = File.basename(course_thumbnail.text)[/.*?(?=[\?&#])/]
          filename = filename.tr!('=', '_')
        elsif course_thumbnail.present?
          filename = File.basename(course_thumbnail.text)
        end

        if course_thumbnail.present? && course_thumbnail.text.present? && course.course_image_file_name != filename
          begin
            Raven.extra_context(course_thumbnail: course_thumbnail.text)
            course.course_image = Course.process_uri(course_thumbnail.text)
          rescue OpenURI::HTTPError, Paperclip::Error => e
            Rails.logger.error "Couldn't process course image in course #{course_element.xpath('course:id').text} for URL #{course_thumbnail.text}: #{e.message}"
            course.course_image = nil
          end
        end

        course.start_date = course_element.xpath('course:start').text if course_element.xpath('course:start').present?
        course.end_date = course_element.xpath('course:end').text if course_element.xpath('course:end').present?
        course.provider_given_duration = course_element.xpath('course:length').text if course_element.xpath('course:length').present?
        course.abstract = course_element.xpath('course:subtitle').text
        course.description = course_element.xpath('description').text

        all_staff = []
        course_element.xpath('course:instructors/course:staff').each do |staff_member|
          all_staff.push(staff_member.xpath('staff:name').text)
        end
        instructors = ''
        all_staff.each do |staff_name|
          instructors += staff_name
          instructors += ', ' if staff_name != all_staff.last
        end
        course.course_instructors = instructors

        course.requirements = nil
        course.requirements = [course_element.xpath('course:prerequisites').text] unless course_element.xpath('course:prerequisites').text == 'None'

        if course_element.xpath('course:subject').present?
          course.categories = []
          course_element.xpath('course:subject').each do |subject|
            course.categories.push(subject.text)
          end
        else
          course.categories = nil
        end

        course.workload = course_element.xpath('course:effort').text if course_element.xpath('course:effort').present?

        if course_element.xpath('course:profed').text == '1'
          profed_track = CourseTrack.find_by(course_id: course.id, track_type: profed_track_type) || CourseTrack.create!(track_type: profed_track_type)
          course.tracks.push profed_track
        else
          free_track = CourseTrack.find_by(course_id: course.id, track_type: free_track_type) || CourseTrack.create!(track_type: free_track_type, costs: 0.0, costs_currency: '$')
          course.tracks.push free_track
          if course_element.xpath('course:verified').text == '1'
            certificate_track = CourseTrack.find_by(course_id: course.id, track_type: certificate_track_type) || CourseTrack.create!(track_type: certificate_track_type)
            course.tracks.push certificate_track
          end
          if course_element.xpath('course:xseries').text == '1'
            xseries_track = CourseTrack.find_by(course_id: course.id, track_type: xseries_track_type) || CourseTrack.create!(track_type: xseries_track_type)
            course.tracks.push xseries_track
          end
        end

        course.save!
      end
    end

    evaluate_update_map update_map
  end
end
