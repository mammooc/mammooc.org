class OpenHPIUserWorker
  include Sidekiq::Worker

  def perform(user_ids=nil)
    if user_ids.nil?
      OpenHPIConnector.new.load_user_data nil
    else
      OpenHPIConnector.new.load_user_data User.find(user_ids)
    end
  end

end
