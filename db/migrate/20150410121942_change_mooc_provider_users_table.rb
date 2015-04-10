class ChangeMoocProviderUsersTable < ActiveRecord::Migration
  def change
    drop_table :mooc_provider_users
    create_table :mooc_provider_users, id: :uuid  do |t|
      t.uuid :user_id
      t.references :user, type: 'uuid', index: true
      t.references :mooc_provider, type: 'uuid', index: true
      t.string :authentication_token

      t.timestamps null: false
    end
    add_foreign_key :mooc_provider_users, :users
    add_foreign_key :mooc_provider_users, :mooc_providers
  end
end
