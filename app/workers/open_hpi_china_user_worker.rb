class OpenHPIChinaUserWorker
  include Sidekiq::Worker

  def perform(user_ids=nil)
    if user_ids.nil?
      OpenHPIChinaConnector.new.load_user_data nil
    else
      OpenHPIChinaConnector.new.load_user_data User.find(user_ids)
    end
  end

end
