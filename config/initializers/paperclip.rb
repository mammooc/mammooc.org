# frozen_string_literal: true

Paperclip::DataUriAdapter.register
Paperclip::UriAdapter.register
Paperclip::HttpUrlProxyAdapter.register

Paperclip::Attachment.default_options[:url] = ':s3_path_url'
Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:filename'
Paperclip::Attachment.default_options[:s3_region] = ENV['AWS_REGION']
Paperclip::Attachment.default_options[:s3_host_name] = "s3.dualstack.#{ENV['AWS_REGION']}.amazonaws.com"
Paperclip::Attachment.default_options[:s3_protocol] = :https
Paperclip::Attachment.default_options[:s3_url_options] = {use_dualstack_endpoint: true}
