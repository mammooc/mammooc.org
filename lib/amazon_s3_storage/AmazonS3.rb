require 'aws-sdk'
require 'singleton'

class AmazonS3
  include Singleton

  def initialize
    s3 = AWS::S3::Ressource.new
    @bucket = s3.bucket('mammooc')
  end

  def get_object(key)
    @bucket.object(key)
  end

  def put_object(key)
    object = get_object(key)
    object.upload_file('url')
  end

end
