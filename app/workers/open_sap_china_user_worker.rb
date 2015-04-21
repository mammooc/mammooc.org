class OpenSAPChinaUserWorker
  include Sidekiq::Worker

  def perform(user_ids=nil)
    if user_ids.nil?
      OpenSAPChinaConnector.new.load_user_data nil
    else
      OpenSAPChinaConnector.new.load_user_data User.find(user_ids)
    end
  end

end
