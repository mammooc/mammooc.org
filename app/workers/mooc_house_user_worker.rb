class MoocHouseUserWorker
  include Sidekiq::Worker

  def perform
    MoocHouseConnector.new.load_user_data nil
  end

end
