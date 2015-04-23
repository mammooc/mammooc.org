class OpenUNEUserWorker
  include Sidekiq::Worker

  def perform(user_ids=nil)
    if user_ids.nil?
      OpenUNEConnector.new.load_user_data nil
    else
      OpenUNEConnector.new.load_user_data User.find(user_ids)
    end
  end
end
