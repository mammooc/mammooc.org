# -*- encoding : utf-8 -*-
class UdacityCourseWorker < AbstractCourseWorker
  include Sidekiq::Worker
  require 'rest_client'

  MOOC_PROVIDER_NAME = 'Udacity'
  MOOC_PROVIDER_API_LINK = 'https://www.udacity.com/public-api/v0/courses'

  def mooc_provider
    MoocProvider.find_by_name(MOOC_PROVIDER_NAME)
  end

  def course_data
    response = RestClient.get(MOOC_PROVIDER_API_LINK)
    JSON.parse response
  end

  def handle_response_data(response_data)
    update_map = create_update_map mooc_provider

    free_track_type = CourseTrackType.find_by(type_of_achievement: 'udacity_nothing')
    certificate_track_type = CourseTrackType.find_by(type_of_achievement: 'udacity_verified_certificate')

    response_data['courses'].each do |course_element|
      course = Course.find_by(provider_course_id: course_element['key'].to_s, mooc_provider_id: mooc_provider.id) || Course.new
      update_map[course.id] = true unless course.new_record?

      course.name = course_element['title'].strip
      course.url = course_element['homepage']
      course.abstract = course_element['summary']
      course.language = 'en'
      course.imageId = course_element['image']
      course.videoId = course_element['teaser_video']['youtube_url'] if course_element['teaser_video']['youtube_url']
      course.difficulty = course_element['level'].capitalize

      free_track = CourseTrack.find_by(course_id: course.id, track_type: free_track_type) || CourseTrack.create!(track_type: free_track_type, costs: 0.0, costs_currency: '$')
      course.tracks.push free_track
      if course_element['full_course_available']
        certificate_track = CourseTrack.find_by(course_id: course.id, track_type: certificate_track_type) || CourseTrack.create!(track_type: certificate_track_type)
        course.tracks.push certificate_track
      end

      course.provider_course_id = course_element['key']
      course.mooc_provider_id = mooc_provider.id
      course.categories = course_element['tracks'] unless course_element['tracks'].empty?
      course.requirements = [course_element['required_knowledge']]

      course.course_instructors = ''
      course_element['instructors'].each_with_index do |instructor, i|
        course.course_instructors += "#{(i > 0) ? ', ' : ''}#{instructor['name']}"
      end

      course.description = course_element['expected_learning']
      if course_element['expected_duration'] && course_element['expected_duration_unit']
        course.calculated_duration_in_days = calculate_duration(course_element['expected_duration'], course_element['expected_duration_unit'])
      end
      course.provider_given_duration = "#{course_element['expected_duration']} #{course_element['expected_duration_unit']}"

      course.save!
    end

    evaluate_update_map update_map
  end

  def calculate_duration value, unit
    factor = case unit
               when 'days' then 1
               when 'weeks' then 7
               when 'months' then 30
             end
    return value * factor
  end
end
