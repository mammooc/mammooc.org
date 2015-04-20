class OpenSAPUserWorker
  include Sidekiq::Worker

  def perform
    OpenSAPConnector.new.load_user_data nil
  end

end
