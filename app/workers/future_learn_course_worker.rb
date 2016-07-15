# frozen_string_literal: true

class FutureLearnCourseWorker < AbstractCourseWorker
  MOOC_PROVIDER_NAME = 'FutureLearn'
  MOOC_PROVIDER_API_LINK = 'https://www.futurelearn.com/feeds/courses'

  def mooc_provider
    MoocProvider.find_by_name(MOOC_PROVIDER_NAME)
  end

  def course_data
    response = RestClient.get(MOOC_PROVIDER_API_LINK)
    JSON.parse response
  end

  def handle_response_data(response_data)
    update_map = create_update_map mooc_provider

    free_track_type = CourseTrackType.find_by(type_of_achievement: 'nothing')
    certificate_track_type = CourseTrackType.find_by(type_of_achievement: 'certificate')

    response_data.each do |course_element|
      name = course_element['name'].strip
      url = course_element['url']
      abstract = course_element['introduction']
      description = course_element['description']
      language = course_element['language']
      image_url = course_element['image_url']
      trailer = course_element['trailer']
      categories = course_element['categories']
      instructors = course_element['educator']
      workload = "#{course_element['hours_per_week']} hours per week"
      organisation_name = course_element['organisation']['name']
      organisation_url = course_element['organisation']['url']
      organisation = Organisation.find_or_create_by(name: organisation_name, url: organisation_url)

      sorted_runs = course_element['runs'].sort_by {|run| run['start_date'] ? run['start_date'] : run['uuid'] }
      sorted_runs.each_with_index do |run, index|
        course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, run['uuid']) || Course.new
        update_map[course.id] = true unless course.new_record?

        course.name = name
        course.url = url
        course.abstract = abstract
        course.description = description
        course.language = language
        course.organisation = organisation

        if image_url[/[\?&#]/]
          filename = File.basename(image_url)[/.*?(?=[\?&#])/]
          filename = filename.tr!('=', '_')
        else
          filename = File.basename(image_url)
        end

        if course.course_image_file_name != filename
          begin
            course.course_image = Course.process_uri(image_url)
          rescue OpenURI::HTTPError => e
            Rails.logger.error "Couldn't process course image in course #{run['uuid']} for URL #{image_url}: #{e.message}"
            course.course_image = nil
          end
        end

        course.videoId = trailer
        course.start_date = run['start_date']

        if course_element['has_certificates']
          certificate_track = CourseTrack.find_by(course_id: course.id, track_type: certificate_track_type) || CourseTrack.create!(track_type: certificate_track_type)
          course.tracks.push certificate_track
        else
          free_track = CourseTrack.find_by(course_id: course.id, track_type: free_track_type) || CourseTrack.create!(track_type: free_track_type, costs: 0.0, costs_currency: '$')
          course.tracks.push free_track
        end

        course.provider_course_id = run['uuid']
        course.mooc_provider_id = mooc_provider.id
        course.categories = categories

        course.course_instructors = instructors
        course.workload = workload

        course.provider_given_duration = "#{run['duration_in_weeks']} weeks"
        course.calculated_duration_in_days = calculate_duration(run['duration_in_weeks'])

        if index > 0 && run['start_date']
          if sorted_runs[index - 1]['start_date']
            previous_iteration_uuid = sorted_runs[index - 1]['uuid']
            previous_course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, previous_iteration_uuid)
            course.previous_iteration = previous_course
            previous_course.following_iteration = course
            previous_course.save!
          end
        end

        course.save!
      end
    end

    evaluate_update_map update_map
  end

  def calculate_duration(duration)
    duration * 7
  end
end
