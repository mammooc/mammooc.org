class AddOAuthPathForLoginToMoocProvider < ActiveRecord::Migration
  def change
    add_column :mooc_providers, :oauth_path_for_login, :string, default: nil
  end
end
