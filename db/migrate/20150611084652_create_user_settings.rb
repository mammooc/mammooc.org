# encoding: utf-8
# frozen_string_literal: true

class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings, id: :uuid do |t|
      t.string :name
      t.references :user, type: 'uuid', index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
