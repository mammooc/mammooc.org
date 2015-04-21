class OpenSAPUserWorker
  include Sidekiq::Worker

  def perform(user_ids=nil)
    if user_ids.nil?
      OpenSAPConnector.new.load_user_data nil
    else
      OpenSAPConnector.new.load_user_data User.find(user_ids)
    end
  end

end
