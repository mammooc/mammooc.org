# frozen_string_literal: true

class RenameMoocProviderOAuthPathForLogin < ActiveRecord::Migration[5.1]
  def change
    rename_column :mooc_providers, :oauth_path_for_login, :oauth_strategy_name

    MoocProvider.all.each do |provider|
      next unless provider.oauth_strategy_name.present? && provider.oauth_strategy_name.start_with?('/users/auth/')
      provider.oauth_strategy_name.slice! '/users/auth/'
      provider.save!
    end
  end
end
