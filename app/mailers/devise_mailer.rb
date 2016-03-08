# encoding: utf-8
# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  def headers_for(action, opts)
    headers = {
      subject: subject_for(action),
      to: resource.primary_email,
      from: mailer_sender(devise_mapping),
      reply_to: mailer_reply_to(devise_mapping),
      template_path: template_paths,
      template_name: action
    }.merge(opts)

    @email = headers[:to]
    headers
  end
end
