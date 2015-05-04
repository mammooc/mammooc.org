class IversityCourseWorker < AbstractCourseWorker
  include Sidekiq::Worker
  require 'rest_client'

  MOOC_PROVIDER_NAME = 'iversity'
  MOOC_PROVIDER_API_LINK = 'https://iversity.org/api/v1/courses'

  def mooc_provider
    MoocProvider.find_by_name(MOOC_PROVIDER_NAME)
  end

  def get_course_data
    response = RestClient.get(MOOC_PROVIDER_API_LINK)
    JSON.parse response
  end

  def handle_response_data response_data
    update_map = create_update_map mooc_provider

    free_track_type = CourseTrackType.find_by(type_of_achievement: 'iversity_record_of_achievement')
    certificate_track_type = CourseTrackType.find_by(type_of_achievement: 'iversity_certificate')
    ects_track_type = CourseTrackType.find_by(type_of_achievement: 'iversity_ects')

    response_data['courses'].each do |course_element|
      course = Course.find_by(provider_course_id: course_element['id'].to_s, mooc_provider_id: mooc_provider.id) || Course.new
      update_map[course.id] = true unless course.new_record?

      course.name = course_element['title']
      course.url = course_element['url']
      course.abstract = course_element['subtitle']
      course.language = course_element['language']
      course.imageId = course_element['image']
      course.videoId = course_element['trailer_video']
      course.start_date = course_element['start_date']
      course.end_date = course_element['end_date']
      course.difficulty = course_element['knowledge_level ']

      course_element['plans'].each do |plan|
        price = plan['price'].split(" ") unless plan['price'].blank?
        track_attributes = Hash.new
        case plan['title'].split(/[\s-]/)[0].downcase
          when 'audit' then track_attributes = {track_type: free_track_type}
          when 'certificate' then track_attributes = {track_type: certificate_track_type, costs: price[0].to_f, costs_currency: price[1]}
          when 'ects'
            track_attributes = {track_type: ects_track_type, costs: price[0].to_f, costs_currency: price[1]}
            track_attributes.merge!(credit_points: (plan['credits'].split(" "))[0].to_f) unless plan['credits'].blank?
        end
        track = CourseTrack.find_by(course_id: course.id, track_type: track_attributes[:track_type]) || CourseTrack.create!(track_attributes)
        course.tracks.push track
      end

      course.provider_course_id = course_element['id']
      course.mooc_provider_id = mooc_provider.id
      course.categories = [course_element['discipline']]

      course.course_instructors = ""
      course_element['instructors'].each_with_index do |instructor, i|
        course.course_instructors += "#{(i > 0) ? ', ' : ''}#{instructor['name']}"
      end

      course.description = course_element['description']
      course.calculated_duration_in_days = (course.end_date - course.start_date).to_i
      course.provider_given_duration = course_element['duration']

      course.save!
    end

    evaluate_update_map update_map
  end
end
