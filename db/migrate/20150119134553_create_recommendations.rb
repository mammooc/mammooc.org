# encoding: utf-8
# frozen_string_literal: true

class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations, id: :uuid do |t|
      t.boolean :is_obligatory
      t.references :user, type: 'uuid', index: true
      t.references :group, type: 'uuid', index: true
      t.references :course, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :recommendations, :users
    add_foreign_key :recommendations, :groups
    add_foreign_key :recommendations, :courses
  end
end
