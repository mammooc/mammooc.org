# frozen_string_literal: true

class AddOAuthRefreshTokenAndAccessTokenToMoocProviderUsers < ActiveRecord::Migration[4.2]
  def change
    change_table(:mooc_provider_users, bulk: true) do |t|
      t.remove :authentication_token
      t.string :refresh_token
      t.string :access_token
      t.timestamp :access_token_valid_until
    end
  end
end
