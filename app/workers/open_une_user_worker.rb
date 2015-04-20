class OpenUNEUserWorker
  include Sidekiq::Worker

  def perform
    OpenUNEConnector.new.load_user_data nil
  end

end
