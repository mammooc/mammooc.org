require 'aws-sdk'
require 'singleton'

class AmazonS3
  include Singleton

  BUCKET_NAME = 'mammooc'

  def initialize
    new_aws_resource
  end

  def get_object(key)
    @bucket.object(key)
  end

  def get_data(key)
    @bucket.object(key).get.body.read
  end

  def get_provider_logos_hash_for_courses(courses)
    logos = {}
    courses.each do |course|
      unless logos.has_key?(course.mooc_provider.logo_id)
        logos[course.mooc_provider.logo_id] = get_url(course.mooc_provider.logo_id)
      end
    end

    return logos

  end

  def get_url(key)
    @bucket.object(key).presigned_url 'GET'
  end

  def get_all_provider_logos_hash
    logos = {}
    MoocProvider.find_each do |provider|
      logos[provider.logo_id] = get_url(provider.logo_id)
    end

    return logos

  end

  def get_provider_logos_hash_for_recommendations(recommendations)
    logos = {}
    recommendations.each do |recommendation|
      unless logos.has_key?(recommendation.course.mooc_provider.logo_id)
        logos[recommendation.course.mooc_provider.logo_id] = get_url(recommendation.course.mooc_provider.logo_id)
      end
    end

    return logos

  end

  def get_author_profile_images_hash_for_recommendations(recommendations)
    author_images = {}
    recommendations.each do |recommendation|
      unless author_images.has_key?(recommendation.author.profile_image_id)
        author_images[recommendation.author.profile_image_id] = get_url(recommendation.author.profile_image_id)
      end
    end

    return author_images

  end

  def get_user_profile_images_hash_for_users(users, images = {})
    users.each do |user|
      unless images.has_key?(user.profile_image_id)
        images[user.profile_image_id] = get_url(user.profile_image_id)
      end
    end
    return images
  end

  def put_data(key, file, options_hash={})
    object = get_object(key)

    unless options_hash.has_key?(:cache_control_time_in_seconds)
      options_hash[:cache_control_time_in_seconds] = 1296000
    end

    object.put(body: file, content_encoding: options_hash[:content_encoding], content_type: options_hash[:content_type], cache_control: "max-age=#{options_hash[:cache_control_time_in_seconds]}", storage_class: 'REDUCED_REDUNDANCY')
  end

  private
    def new_aws_resource
      s3 = Aws::S3::Resource.new
      @bucket = s3.bucket(BUCKET_NAME)
    end

end
