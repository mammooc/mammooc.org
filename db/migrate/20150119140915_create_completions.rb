# frozen_string_literal: true

class CreateCompletions < ActiveRecord::Migration[4.2]
  def change
    create_table :completions, id: :uuid do |t|
      t.integer :position_in_course
      t.float :points
      t.string :permissions, array: true
      t.datetime :date
      t.references :user, type: 'uuid', index: true
      t.references :course, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :completions, :users
    add_foreign_key :completions, :courses
  end
end
