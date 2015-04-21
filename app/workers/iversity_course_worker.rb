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
    response_data['courses'].each do |course_element|
      puts course_element['id'].inspect
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

      course_element['plans'].each do |plan|
        if plan['price'].nil?
          course.has_free_version = true
        else
          course.has_paid_version = true
          price = plan['price'].split(' ')
          course.costs = price[0].to_f
          course.price_currency = price[1]
        end
      end

      #course.type_of_achievement =
    end
    puts update_map.inspect
    evaluate_update_map update_map
  end
end
