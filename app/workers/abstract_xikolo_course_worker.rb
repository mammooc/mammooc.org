# -*- encoding : utf-8 -*-
class AbstractXikoloCourseWorker < AbstractCourseWorker
  MOOC_PROVIDER_NAME = ''
  MOOC_PROVIDER_API_LINK = ''
  COURSE_LINK_BODY = ''
  MOOC_PROVIDER_COURSES_API = 'courses'
  MOOC_PROVIDER_CATEGORIES_API = 'categories'

  def mooc_provider
    MoocProvider.find_by_name(self.class::MOOC_PROVIDER_NAME)
  end

  def course_data
    response = RestClient.get(self.class::MOOC_PROVIDER_API_LINK + MOOC_PROVIDER_COURSES_API, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: 'token=\"78783786789\"')
    response.present? ? JSON.parse(response) : []
  end

  def handle_response_data(response_data)
    update_map = create_update_map mooc_provider
    course_track_type = CourseTrackType.find_by(type_of_achievement: 'xikolo_record_of_achievement')

    all_teachers = prepare_teachers_hash(response_data['teachers'])
    all_categories = prepare_categories_hash

    response_data['courses'].each do |course_element|
      next if course_element['isExternal'] || course_element['isHidden'] || course_element['isInviteOnly']
      course = Course.find_by(provider_course_id: course_element['id'], mooc_provider_id: mooc_provider.id)
      if course.nil?
        course = Course.new
      else
        update_map[course.id] = true
      end

      course.name = course_element['name'].strip
      course.provider_course_id = course_element['id']
      course.mooc_provider_id = mooc_provider.id
      course.url = self.class::ROOT_URL + course_element['urls']['details']
      course.language = course_element['language']
      course.imageId = self.class::ROOT_URL + course_element['image']
      course.start_date = course_element['displayStartDate']
      course.end_date = course_element['endDate']
      course.abstract = convert_to_absolute_urls(parse_markdown(course_element['abstract']))
      # course.description = convert_to_absolute_urls(parse_markdown(course_element['description']))
      course.course_instructors = translate_teachers(course_element['teachers'], all_teachers)
      course.categories = translate_categories(course_element['categories'], all_categories)
      course.open_for_registration = course_element['status'] == 'active' || course_element[''] == 'archive'
      # course.points_maximal = course_element['points_maximal']
      track = CourseTrack.find_by(course_id: course.id, track_type: course_track_type) || CourseTrack.create!(track_type: course_track_type, costs: 0.0, costs_currency: "\xe2\x82\xac")
      course.tracks.push(track)
      course.save!
    end
    evaluate_update_map update_map
  end

  def prepare_teachers_hash(all_teachers)
    hash = {}
    all_teachers.each do |teacher|
      hash[teacher['id']] = teacher['name']
    end
    hash
  end

  def translate_teachers(course_teachers, all_teachers)
    string = ''
    course_teachers.each do |teacher|
      string += "#{all_teachers[teacher]}, "
    end
    string.present? ? string[0...-2] : string
  end

  def prepare_categories_hash
    response = RestClient.get(self.class::MOOC_PROVIDER_API_LINK + MOOC_PROVIDER_CATEGORIES_API, accept: 'application/vnd.xikoloapplication/vnd.xikolo.v1, application/json', authorization: 'token=\"78783786789\"')
    categories = response.present? ? JSON.parse(response) : {}
    hash = {}
    categories['categories'].each do |category|
      hash[category['id']] = category['name']
    end
    hash
  end

  def translate_categories(course_categories, all_categories)
    categories = []
    course_categories.each do |category|
      categories << all_categories[category]
    end
    categories
  end
end
