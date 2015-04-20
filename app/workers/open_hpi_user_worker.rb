class OpenHPIUserWorker
  include Sidekiq::Worker

  def perform
    OpenHPIConnector.new.load_user_data nil
  end

end
