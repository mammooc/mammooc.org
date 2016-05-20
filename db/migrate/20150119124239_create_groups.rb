# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups, id: :uuid do |t|
      t.string :name
      t.string :imageId
      t.text :description
      t.string :primary_statistics, array: true

      t.timestamps null: false
    end
  end
end
