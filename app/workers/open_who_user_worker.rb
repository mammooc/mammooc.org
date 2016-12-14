# frozen_string_literal: true

class OpenWHOUserWorker
  include Sidekiq::Worker

  def perform(user_ids = nil)
    if user_ids.nil?
      OpenWHOConnector.new.load_user_data
    else
      OpenWHOConnector.new.load_user_data User.find(user_ids)
    end
  end
end
