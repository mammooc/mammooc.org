# frozen_string_literal: true

class CreateMoocProvidersUsersJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_table :mooc_providers_users, id: false do |t|
      t.uuid :mooc_provider_id
      t.uuid :user_id
    end
  end
end
