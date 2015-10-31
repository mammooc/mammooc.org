class UserDate < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  belongs_to :mooc_provider

  def self.synchronize(user)
    synchronization_state = {}
    synchronization_state[:openHPI] = OpenHPIConnector.new.load_dates_for_user user
    synchronization_state[:openSAP] = OpenSAPConnector.new.load_dates_for_user user
    synchronization_state
  end

end
