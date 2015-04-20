class OpenSAPChinaUserWorker
  include Sidekiq::Worker

  def perform
    OpenSAPChinaConnector.new.load_user_data nil
  end

end
