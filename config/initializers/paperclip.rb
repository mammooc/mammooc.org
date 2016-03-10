# encoding: utf-8
# frozen_string_literal: true

Paperclip::Attachment.default_options[:url] = ':s3_path_url'
Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:filename'
Paperclip::Attachment.default_options[:s3_host_name] = 's3-eu-west-1.amazonaws.com'
Paperclip::Attachment.default_options[:s3_protocol] = :https
