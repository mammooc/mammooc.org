# frozen_string_literal: true

class AddOAuthPathForLoginToMoocProvider < ActiveRecord::Migration[4.2]
  def change
    add_column :mooc_providers, :oauth_path_for_login, :string, default: nil
  end
end
