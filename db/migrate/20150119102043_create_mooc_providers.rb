# frozen_string_literal: true

class CreateMoocProviders < ActiveRecord::Migration[4.2]
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
