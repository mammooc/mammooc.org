# encoding: utf-8
# frozen_string_literal: true

class CourseraUserWorker
  include Sidekiq::Worker

  def perform(user_ids = nil)
    if user_ids.nil?
      CourseraConnector.new.load_user_data
    else
      CourseraConnector.new.load_user_data User.find(user_ids)
    end
  end
end
