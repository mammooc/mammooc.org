# -*- encoding : utf-8 -*-
class UserDatesWorker
  include Sidekiq::Worker

  def perform
    synchronize_dates_for_all_users
  end

  def synchronize_dates_for_all_users
    OpenHPIConnector.new.load_dates_for_users
    OpenSAPConnector.new.load_dates_for_users
    MoocHouseConnector.new.load_dates_for_users
    CnmoocHouseConnector.new.load_dates_for_users
    OpenHPIChinaConnector.new.load_dates_for_users
    OpenSAPChinaConnector.new.load_dates_for_users
    OpenUNEConnector.new.load_dates_for_users
  end
end
