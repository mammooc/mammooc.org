# frozen_string_literal: true

class IversityCourseWorker < AbstractCourseWorker
  include Sidekiq::Worker
  require 'rest_client'

  MOOC_PROVIDER_NAME = 'iversity'
  MOOC_PROVIDER_API_LINK = 'https://iversity.org/api/v1/courses'

  def mooc_provider
    MoocProvider.find_by(name: MOOC_PROVIDER_NAME)
  end

  def course_data
    response = RestClient.get(MOOC_PROVIDER_API_LINK)
    JSON.parse response
  end

  def handle_response_data(response_data)
    update_map = create_update_map mooc_provider

    free_track_type = CourseTrackType.find_by(type_of_achievement: 'iversity_record_of_achievement')
    certificate_track_type = CourseTrackType.find_by(type_of_achievement: 'iversity_certificate')
    ects_track_type = CourseTrackType.find_by(type_of_achievement: 'iversity_ects')
    ects_pupils_track_type = CourseTrackType.find_by(type_of_achievement: 'iversity_ects_pupils')
    iversity_statement_track = CourseTrackType.find_by(type_of_achievement: 'iversity_statement_of_participation')

    response_data['courses'].each do |course_element|
      course = Course.find_by(provider_course_id: course_element['id'].to_s, mooc_provider_id: mooc_provider.id) || Course.new
      update_map[course.id] = true unless course.new_record?

      course.name = course_element['title'].strip
      course.url = course_element['url']
      course.abstract = course_element['subtitle']
      case course_element['language']
        when 'German' then course.language = 'de'
        when 'English' then course.language = 'en'
        when %w[en es] then course.language = 'en,es'
      end

      if course_element['image'].present? && course_element['image'][/[\?&#]/]
        filename = File.basename(course_element['image'])[/.*?(?=[\?&#])/]
        filename = filename.tr!('=', '_')
      elsif course_element['image'].present?
        filename = File.basename(course_element['image'])
      end

      if course_element['image'].present? && course.course_image_file_name != filename
        begin
          course.course_image = Course.process_uri(course_element['image'])
        rescue OpenURI::HTTPError => e
          Rails.logger.error "Couldn't process course image in course #{course_element['id']} for URL #{course_element['image']}: #{e.message}"
          course.course_image = nil
        end
      end
      course.videoId = course_element['trailer_video']
      course.start_date = course_element['start_date']
      course.end_date = course_element['end_date']
      course.difficulty = course_element['knowledge_level ']

      plan_array = if course_element['verifications'].is_a?(Array)
                     course_element['verifications']
                   else
                     [course_element['verifications']]
                   end
      plan_array.each do |plan|
        price = plan['price'].split(' ') if plan['price'].present?
        if price
          costs = price[0].to_f
          costs_currency = price[1]
        else
          costs = 0.0
          costs_currency = '€'
        end
        track_attributes = {}
        case plan['title'].split(/[\s-]/)[0].downcase
          when 'audit' then track_attributes = {track_type: free_track_type, costs: 0.0, costs_currency: '€'}
          when 'certificate' then track_attributes = {track_type: certificate_track_type, costs: costs, costs_currency: costs_currency}
          when 'ects'
            track_attributes = {track_type: ects_track_type, costs: costs, costs_currency: costs_currency}
            track_attributes[:credit_points] = plan['credits'].split(' ')[0].to_f if plan['credits'].present?
          when 'schüler'
            track_attributes = {track_type: ects_pupils_track_type, costs: costs, costs_currency: costs_currency}
            track_attributes[:credit_points] = plan['credits'].split(' ')[0].to_f if plan['credits'].present?
          when 'statement', 'teilnahmebescheinigung'
            track_attributes = if price.present?
                                 {track_type: iversity_statement_track, costs: costs, costs_currency: costs_currency}
                               else
                                 {track_type: iversity_statement_track, costs: 0.0, costs_currency: "\xe2\x82\xac"}
                               end
        end
        track = CourseTrack.find_by(course_id: course.id, track_type: track_attributes[:track_type]) || CourseTrack.create!(track_attributes)
        course.tracks.push track
      end

      course.provider_course_id = course_element['id']
      course.mooc_provider_id = mooc_provider.id
      course.categories = [course_element['discipline']]

      course.course_instructors = ''

      instructor_array = if course_element['instructors'].is_a?(Array)
                           course_element['instructors']
                         else
                           [course_element['instructors']]
                         end

      instructor_array.each_with_index do |instructor, i|
        course.course_instructors += "#{i.positive? ? ', ' : ''}#{instructor['name']}"
      end

      course.description = course_element['description']
      course.provider_given_duration = course_element['duration']

      course.save!
    end

    evaluate_update_map update_map
  end
end
