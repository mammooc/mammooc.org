# -*- encoding : utf-8 -*-
class EdxCourseWorker < AbstractCourseWorker
  MOOC_PROVIDER_NAME = 'edX'
  MOOC_PROVIDER_API_LINK = 'http://pipes.yahoo.com/pipes/pipe.run?_id=74859f52b084a75005251ae7a119f371&_render=json'

  def mooc_provider
    MoocProvider.find_by_name(self.class::MOOC_PROVIDER_NAME)
  end

  def course_data
    response = RestClient.get(self.class::MOOC_PROVIDER_API_LINK)
    JSON.parse response
  end

  def handle_response_data(response_data)
    update_map = create_update_map mooc_provider

    free_track_type = CourseTrackType.find_by(type_of_achievement: 'nothing')
    certificate_track_type = CourseTrackType.find_by(type_of_achievement: 'edx_verified_certificate')
    xseries_track_type = CourseTrackType.find_by(type_of_achievement: 'edx_xseries_verified_certificate')
    profed_track_type = CourseTrackType.find_by(type_of_achievement: 'edx_profed_certificate')

    response_data['value']['items'].each do |course_element|
      course = Course.find_by(provider_course_id: course_element['course:id'], mooc_provider_id: mooc_provider.id)
      if course.nil?
        course = Course.new
      else
        update_map[course.id] = true
      end

      course.name = course_element['title'].strip
      course.provider_course_id = course_element['course:id']
      course.mooc_provider_id = mooc_provider.id
      course.url = course_element['link']
      course.imageId = course_element['course:image-thumbnail']
      if course_element['course:start']
        course.start_date = course_element['course:start']
      end
      if course_element['course:end']
        course.end_date = course_element['course:end']
      end
      if course_element['course:length']
        course.provider_given_duration = course_element['course:length']
      end
      course.abstract = course_element['course:subtitle']
      course.description = course_element['description']

      temp = ''
      if course_element['course:staff']
        if course_element['course:staff'].class == Array
          course_element['course:staff'].each_with_index do |staff_member, index|
            temp += staff_member
            unless (index == course_element['course:staff'].size - 1)
              temp += ', '
            end
          end
        elsif course_element['course:staff'].class == String
          temp = course_element['course:staff']
        end
        course.course_instructors = temp
      end

      course.requirements = nil
      if course_element['course:prerequisites']
        unless course_element['course:prerequisites'].empty?
          course.requirements = [course_element['course:prerequisites']]
        end
      end

      course.categories = nil
      if course_element['course:subject']
        if course_element['course:subject'].class == Array
          course.categories = course_element['course:subject']
        elsif course_element['course:subject'].class == String
          course.categories = [course_element['course:subject']]
        end
      end

      if course_element['course:effort']
        course.workload = course_element['course:effort']
      end

      if course_element['course:profed'] && course_element['course:profed'] == '1'
        profed_track = CourseTrack.find_by(course_id: course.id, track_type: profed_track_type) || CourseTrack.create!(track_type: profed_track_type)
        course.tracks.push profed_track
      else
        free_track = CourseTrack.find_by(course_id: course.id, track_type: free_track_type) || CourseTrack.create!(track_type: free_track_type, costs: 0.0, costs_currency: '$')
        course.tracks.push free_track
        if course_element['course:verified'] && course_element['course:verified'] == '1'
          certificate_track = CourseTrack.find_by(course_id: course.id, track_type: certificate_track_type) || CourseTrack.create!(track_type: certificate_track_type)
          course.tracks.push certificate_track
        end
        if course_element['course:xseries'] && course_element['course:xseries'] == '1'
          xseries_track = CourseTrack.find_by(course_id: course.id, track_type: xseries_track_type) || CourseTrack.create!(track_type: xseries_track_type)
          course.tracks.push xseries_track
        end
      end

      course.save!
    end
    evaluate_update_map update_map
  end
end
