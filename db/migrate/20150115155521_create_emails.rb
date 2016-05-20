# frozen_string_literal: true

class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails, id: :uuid do |t|
      t.string :address
      t.boolean :is_primary
      t.references :user, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :emails, :users
  end
end
