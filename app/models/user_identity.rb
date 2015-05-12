class UserIdentity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :provider_user_id, :omniauth_provider
  validates_uniqueness_of :provider_user_id, scope: :omniauth_provider

  def self.find_for_omniauth(authentication_info)
    find_or_create_by(provider_user_id: authentication_info.uid, omniauth_provider: authentication_info.provider)
  end
end
