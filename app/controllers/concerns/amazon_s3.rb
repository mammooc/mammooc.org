require 'aws-sdk'
require 'singleton'

class AmazonS3
  include Singleton

  BUCKET_NAME = 'mammooc'

  def initialize
    s3 = Aws::S3::Resource.new
    @bucket = s3.bucket(BUCKET_NAME)
  end

  def get_object(key)
    @bucket.object(key)
  end

  def get_data(key)
    @bucket.object(key).get.body.read
  end

  def put_object(key, file, options_hash={})
    object = get_object(key)
    object.put(body: file, content_encoding: options_hash[:content_encoding], content_type: options_hash[:content_type])
  end

end
