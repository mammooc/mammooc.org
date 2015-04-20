class OpenHPIChinaUserWorker
  include Sidekiq::Worker

  def perform
    OpenHPIChinaConnector.new.load_user_data nil
  end

end
