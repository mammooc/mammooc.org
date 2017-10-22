# frozen_string_literal: true

class CreateUserSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :user_settings, id: :uuid do |t|
      t.string :name
      t.references :user, type: 'uuid', index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
