class DropMoocProvidersUsersTable < ActiveRecord::Migration
  def change
    drop_table :mooc_providers_users
  end
end
