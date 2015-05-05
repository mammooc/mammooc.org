# -*- encoding : utf-8 -*-
class CreateCourseAssignments < ActiveRecord::Migration
  def change
    create_table :course_assignments, id: :uuid  do |t|
      t.string :name
      t.datetime :deadline
      t.float :maximum_score
      t.float :average_score
      t.references :course,  type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :course_assignments, :courses
  end
end
