# encoding: utf-8
# frozen_string_literal: true

class CourseraCourseWorker < AbstractCourseWorker
  MOOC_PROVIDER_NAME = 'coursera'.freeze
  MOOC_PROVIDER_COURSE_API_LINK = 'https://api.coursera.org/api/catalog.v1/courses'.freeze
  MOOC_PROVIDER_COURSE_FIELDS = '?fields=language,subtitleLanguagesCsv,shortDescription,photo,aboutTheCourse,video,targetAudience,instructor,estimatedClassWorkload,recommendedBackground'.freeze
  MOOC_PROVIDER_SESSIONS_API_LINK = 'https://api.coursera.org/api/catalog.v1/sessions'.freeze
  MOOC_PROVIDER_SESSIONS_FIELDS = '?fields=courseId,startDay,startMonth,startYear,durationString,active,eligibleForCertificates,eligibleForSignatureTrack,signatureTrackPrice,signatureTrackRegularPrice'.freeze
  COURSE_LINK_BODY = 'https://www.coursera.org/course/'.freeze
  TARGET_AUDIENCE_0 = 'Basic Undergraduates'.freeze
  TARGET_AUDIENCE_1 = 'Advanced undergraduates or beginning graduates'.freeze
  TARGET_AUDIENCE_2 = 'Advanced graduates'.freeze

  def mooc_provider
    MoocProvider.find_by_name(MOOC_PROVIDER_NAME)
  end

  def course_data
    response = RestClient.get(MOOC_PROVIDER_SESSIONS_API_LINK + MOOC_PROVIDER_SESSIONS_FIELDS)
    JSON.parse response
  end

  def handle_response_data(response_data)
    course_data = RestClient.get(MOOC_PROVIDER_COURSE_API_LINK + MOOC_PROVIDER_COURSE_FIELDS)
    parsed_course_data = JSON.parse course_data

    update_map = create_update_map mooc_provider
    iteration_hash = {}

    free_track_type = CourseTrackType.find_by(type_of_achievement: 'nothing')
    certificate_track_type = CourseTrackType.find_by(type_of_achievement: 'certificate')
    signature_track_type = CourseTrackType.find_by(type_of_achievement: 'coursera_verified_certificate')

    response_data['elements'].each do |session_element|
      course = Course.find_by(provider_course_id: session_element['courseId'].to_s + '|' + session_element['id'].to_s, mooc_provider_id: mooc_provider.id)
      if course.nil?
        course = Course.new
      else
        update_map[course.id] = true
      end

      # find course corresponding to the session
      corresponding_course = parsed_course_data['elements'].find {|json_course| json_course['id'] == session_element['courseId'] }

      course.name = corresponding_course['name'].strip
      course.provider_course_id = session_element['courseId'].to_s + '|' + session_element['id'].to_s
      course.provider_given_duration = session_element['durationString'] unless session_element['durationString'] == ''
      course.calculated_duration_in_days = parse_provider_given_duration session_element['durationString'] unless session_element['durationString'] == ''
      course.mooc_provider_id = mooc_provider.id
      course.url = COURSE_LINK_BODY + corresponding_course['shortName']
      course.language = corresponding_course['language']

      if corresponding_course['photo'].present? && corresponding_course['photo'][/[\?&#]/]
        filename = File.basename(corresponding_course['photo'])[/.*?(?=[\?&#])/]
        filename = filename.tr!('=', '_')
      elsif corresponding_course['photo'].present?
        filename = File.basename(corresponding_course['photo'])
      end

      if corresponding_course['photo'].present? && course.course_image_file_name != filename
        course.course_image = Course.process_uri(corresponding_course['photo'])
      end
      course.abstract = corresponding_course['shortDescription']
      course.course_instructors = corresponding_course['instructor']
      course.subtitle_languages = corresponding_course['subtitleLanguagesCsv']
      course.videoId = corresponding_course['video']
      course.description = corresponding_course['aboutTheCourse']
      course.workload = corresponding_course['estimatedClassWorkload']

      course.difficulty = case corresponding_course['targetAudience']
                            when 0 then TARGET_AUDIENCE_0
                            when 1 then TARGET_AUDIENCE_1
                            when 2 then TARGET_AUDIENCE_2
                          end

      if session_element['startYear'] && session_element['startMonth'] && session_element['startDay']
        course.start_date = Time.zone.local(session_element['startYear'], session_element['startMonth'], session_element['startDay'])
      end

      course.requirements = if corresponding_course['recommendedBackground'].length > 0
                              [corresponding_course['recommendedBackground']]
                            end

      free_track = CourseTrack.find_by(course_id: course.id, track_type: free_track_type) || CourseTrack.create!(track_type: free_track_type, costs: 0.0, costs_currency: '$')
      course.tracks.push(free_track)
      if session_element['eligibleForCertificates']
        certificate_track = CourseTrack.find_by(course_id: course.id, track_type: certificate_track_type) || CourseTrack.create!(track_type: certificate_track_type)
        course.tracks.push(certificate_track)
      end
      if session_element['eligibleForSignatureTrack']
        signature_track = CourseTrack.find_by(course_id: course.id, track_type: signature_track_type) || CourseTrack.create!(track_type: signature_track_type)
        signature_track.costs = if session_element['signatureTrackPrice']
                                  session_element['signatureTrackPrice'].to_f
                                else
                                  session_element['signatureTrackRegularPrice'].to_f
                                end
        signature_track.costs_currency = '$'
        signature_track.save!
        course.tracks.push(signature_track)
      end

      # multiple iterations
      unless iteration_hash[corresponding_course['id']]
        iteration_hash[corresponding_course['id']] = []
      end
      course.save!
      iteration_hash[corresponding_course['id']] << course.id
    end
    evaluate_update_map update_map
    # multiple iterations
    evaluate_iteration_hash iteration_hash
  end
end

def parse_provider_given_duration(provider_given_duration)
  provider_given_duration.split(' ')[0].to_i * 7
end

def evaluate_iteration_hash(iteration_hash)
  iteration_hash.each do |_, course_id_array|
    # filter out courses without a start data, if there is another iteration that has one
    iterations_deletable = false
    course_id_array.each do |id|
      iterations_deletable = true if Course.find(id).start_date
    end
    if iterations_deletable
      course_id_array.each do |id|
        course = Course.find(id)
        unless course.start_date
          course_id_array.delete(id)
          course.destroy
        end
      end
    end
    # sort courses depending on their start date
    course_id_array.sort! do |a, b|
      course1 = Course.find(a)
      course2 = Course.find(b)
      if course1.start_date && course2.start_date
        course1.start_date <=> course2.start_date
      else
        a <=> b
      end
    end
    # link the remaining iterations
    (1...course_id_array.size).each do |index|
      course = Course.find(course_id_array[index])
      course.previous_iteration_id = course_id_array[index - 1]
      course.save
    end
  end
end
