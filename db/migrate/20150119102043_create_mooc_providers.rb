# encoding: utf-8
# frozen_string_literal: true

class CreateMoocProviders < ActiveRecord::Migration
  def change
    create_table :mooc_providers, id: :uuid do |t|
      t.string :logo_id
      t.string :name
      t.string :url
      t.text :description

      t.timestamps null: false
    end
  end
end
