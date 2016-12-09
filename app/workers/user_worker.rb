# frozen_string_literal: true

class UserWorker
  include Sidekiq::Worker

  def perform(user_ids = nil)
    OpenHPIUserWorker.perform_async user_ids
    OpenSAPUserWorker.perform_async user_ids
    MoocHouseUserWorker.perform_async user_ids
    CnmoocHouseUserWorker.perform_async user_ids
    OpenHPIChinaUserWorker.perform_async user_ids
    OpenUNEUserWorker.perform_async user_ids
    OpenWHOUserWorker.perform_async user_ids
    CourseraUserWorker.perform_async user_ids
  end
end
