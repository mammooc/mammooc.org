# encoding: utf-8
# frozen_string_literal: true

class OpenUNEUserWorker
  include Sidekiq::Worker

  def perform(user_ids = nil)
    if user_ids.nil?
      OpenUNEConnector.new.load_user_data
    else
      OpenUNEConnector.new.load_user_data User.find(user_ids)
    end
  end
end
