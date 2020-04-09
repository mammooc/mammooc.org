# frozen_string_literal: true

class LernenCloudUserWorker
  include Sidekiq::Worker

  def perform(user_ids = nil)
    if user_ids.nil?
      LernenCloudConnector.new.load_user_data
    else
      LernenCloudConnector.new.load_user_data User.find(user_ids)
    end
  end
end
