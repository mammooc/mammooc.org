# -*- encoding : utf-8 -*-
class AddAttributeAuthorizationTokenToMoocProvidersUsers < ActiveRecord::Migration
  def change
    add_column(:mooc_providers_users, :authentication_token, :string)
  end
end
