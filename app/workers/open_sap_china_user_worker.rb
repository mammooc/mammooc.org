# frozen_string_literal: true

class OpenSAPChinaUserWorker
  include Sidekiq::Worker

  def perform(user_ids = nil)
    if user_ids.nil?
      OpenSAPChinaConnector.new.load_user_data
    else
      OpenSAPChinaConnector.new.load_user_data User.find(user_ids)
    end
  end
end
