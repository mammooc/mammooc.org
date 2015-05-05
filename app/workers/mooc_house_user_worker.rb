# -*- encoding : utf-8 -*-
class MoocHouseUserWorker
  include Sidekiq::Worker

  def perform(user_ids = nil)
    if user_ids.nil?
      MoocHouseConnector.new.load_user_data
    else
      MoocHouseConnector.new.load_user_data User.find(user_ids)
    end
  end
end
