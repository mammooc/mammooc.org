# frozen_string_literal: true

class AddOAuthRefreshTokenAndAccessTokenToMoocProviderUsers < ActiveRecord::Migration
  def change
    remove_column(:mooc_provider_users, :authentication_token)
    add_column(:mooc_provider_users, :refresh_token, :string)
    add_column(:mooc_provider_users, :access_token, :string)
    add_column(:mooc_provider_users, :access_token_valid_until, :timestamp)
  end
end
