class CreateMoocProviderUsers < ActiveRecord::Migration
  def change
    create_table :mooc_provider_users do |t|
      t.uuid :user_id
      t.uuid :mooc_provider_id
      t.string :authentication_token

      t.timestamps null: false
    end
  end
end
