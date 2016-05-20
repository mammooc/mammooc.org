# frozen_string_literal: true

class CreateUserIdentities < ActiveRecord::Migration
  def change
    create_table :user_identities, id: :uuid do |t|
      t.references :user, type: 'uuid', index: true, foreign_key: true
      t.string :omniauth_provider
      t.string :provider_user_id

      t.timestamps null: false
    end
  end
end
