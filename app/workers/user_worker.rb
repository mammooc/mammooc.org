# -*- encoding : utf-8 -*-
class UserWorker
  include Sidekiq::Worker

  def perform(user_ids = nil)
    OpenHPIUserWorker.perform_async user_ids
    OpenSAPUserWorker.perform_async user_ids
    MoocHouseUserWorker.perform_async user_ids
    OpenHPIChinaUserWorker.perform_async user_ids
    OpenSAPChinaUserWorker.perform_async user_ids
    OpenUNEUserWorker.perform_async user_ids
  end
end
