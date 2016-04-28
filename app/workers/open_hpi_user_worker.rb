# encoding: utf-8
# frozen_string_literal: true

class OpenHPIUserWorker
  include Sidekiq::Worker

  def perform(user_ids = nil)
    if user_ids.nil?
      OpenHPIConnector.new.load_user_data
    else
      OpenHPIConnector.new.load_user_data User.find(user_ids)
    end
  end
end
