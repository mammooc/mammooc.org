# -*- encoding : utf-8 -*-
class CnmoocHouseUserWorker
  include Sidekiq::Worker

  def perform(user_ids = nil)
    if user_ids.nil?
      CnmoocHouseConnector.new.load_user_data
    else
      CnmoocHouseConnector.new.load_user_data User.find(user_ids)
    end
  end
end
