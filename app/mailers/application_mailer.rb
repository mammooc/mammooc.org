# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Settings.sender_notification_address
end
