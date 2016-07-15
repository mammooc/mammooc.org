# frozen_string_literal: true

class CourseraCourseWorker < AbstractCourseWorker
  MOOC_PROVIDER_NAME = 'coursera'
  MOOC_PROVIDER_COURSE_API_LINK = 'https://api.coursera.org/api/courses.v1'
  MOOC_PROVIDER_COURSE_FIELDS = '?includes=instructorIds,partnerIds&fields=primaryLanguages,subtitleLanguages,partnerLogo,instructorIds,partnerIds,photoUrl,certificates,description,startDate,workload,domainTypes,partners.v1(links),instructors.v1(firstName,prefixName,lastName)'

  COURSE_LINK_BODY_V1  = 'https://www.coursera.org/course/'
  COURSE_LINK_BODY_V2  = 'https://www.coursera.org/learn/'

  def mooc_provider
    MoocProvider.find_by_name(MOOC_PROVIDER_NAME)
  end

  def course_data
    response = []

    iterations = 0
    start = 0
    firt_part_response = RestClient.get(MOOC_PROVIDER_COURSE_API_LINK + MOOC_PROVIDER_COURSE_FIELDS + "&start=#{start}")
    iterations += 1
    firt_part_response = JSON.parse firt_part_response
    response.push(firt_part_response)

    start_of_next_part = firt_part_response['paging']['next']

    while start_of_next_part.present?
      next_part_response = RestClient.get(MOOC_PROVIDER_COURSE_API_LINK + MOOC_PROVIDER_COURSE_FIELDS + "&start=#{start_of_next_part}")
      iterations += 1
      next_part_response = JSON.parse next_part_response
      response.push(next_part_response)

      start_of_next_part = next_part_response['paging']['next']
    end

    response
  end

  def handle_response_data(response_data)
    update_map = create_update_map mooc_provider

    free_track_type = CourseTrackType.find_by(type_of_achievement: 'nothing')
    certificate_track_type = CourseTrackType.find_by(type_of_achievement: 'certificate')

    response_data.each do |part_response_data|
      part_response_data['elements'].each do |course_element|
        course = Course.find_or_initialize_by(provider_course_id: course_element['id'], mooc_provider_id: mooc_provider.id)

        update_map[course.id] = true if update_map[course.id] == false

        course.name = course_element['name'].strip
        course.provider_course_id = course_element['id']
        course.mooc_provider_id = mooc_provider.id
        course.language = course_element['primaryLanguages'].join(',')

        if course_element['photoUrl'].present? && course_element['photoUrl'][/[\?&#]/]
          filename = File.basename(course_element['photoUrl'])[/.*?(?=[\?&#])/]
          filename = filename.tr!('=', '_')
        elsif course_element['photoUrl'].present?
          filename = File.basename(course_element['photoUrl'])
        end

        if course_element['photoUrl'].present? && course.course_image_file_name != filename
          begin
            course.course_image = Course.process_uri(course_element['photoUrl'])
          rescue OpenURI::HTTPError => e
            Rails.logger.error "Couldn't process course image in course #{course_element['id'].to_s} for URL #{course_element['photoUrl']}: #{e.message}"
            course.course_image = nil
          end
        end

        course.subtitle_languages = course_element['subtitleLanguages'].join(',')
        course.description = course_element['description']
        course.workload = course_element['workload']

        if course_element['startDate'].present?
          course.start_date = Time.at(course_element['startDate'] / 1000).utc
        end

        if course_element['courseType'].include? 'v1'
          course.url = COURSE_LINK_BODY_V1 + course_element['slug']
        elsif course_element['courseType'].include? 'v2'
          course.url = COURSE_LINK_BODY_V2 + course_element['slug']
        end

        course_instructors = []

        course_element['instructorIds'].each do |instructor_id|
          instructor = part_response_data['linked']['instructors.v1'].find {|instructor_element| instructor_element['id'] == instructor_id }
          instructor_name = (instructor['prefixName'] || '') + ' ' + (instructor['firstName'] || '') + ' ' + (instructor['lastName'] || '')
          course_instructors.push(instructor_name.strip)
        end

        course.course_instructors = course_instructors.join(', ')

        free_track = CourseTrack.find_by(course_id: course.id, track_type: free_track_type) || CourseTrack.create!(track_type: free_track_type, costs: 0.0, costs_currency: '$')
        course.tracks.push(free_track)
        if course_element['certificates'].include? 'VerifiedCert'
          certificate_track = CourseTrack.find_by(course_id: course.id, track_type: certificate_track_type) || CourseTrack.create!(track_type: certificate_track_type)
          course.tracks.push(certificate_track)
        end

        categories = Set.new
        course_element['domainTypes'].each do |domain_element|
          categories.add(domain_element['domainId'])
        end

        course.categories = categories.to_a

        partner_id = course_element['partnerIds'].first
        partner = part_response_data['linked']['partners.v1'].find {|partner_element| partner_element['id'] == partner_id }
        organisation = Organisation.find_or_create_by(name: partner['name'], url: partner['links']['website'])
        course.organisation = organisation

        course.save!
      end
    end
    evaluate_update_map update_map
  end
end
