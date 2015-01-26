class CreateMoocProvidersUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :mooc_providers_users, id: false do |t|
      t.uuid :mooc_provider_id
      t.uuid :user_id
    end
  end
end
