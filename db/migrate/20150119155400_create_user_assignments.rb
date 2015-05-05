# -*- encoding : utf-8 -*-
class CreateUserAssignments < ActiveRecord::Migration
  def change
    create_table :user_assignments, id: :uuid do |t|
      t.datetime :date
      t.float :score
      t.references :user, type: 'uuid', index: true
      t.references :course, type: 'uuid', index: true
      t.references :course_assignment, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :user_assignments, :users
    add_foreign_key :user_assignments, :courses
    add_foreign_key :user_assignments, :course_assignments
  end
end
