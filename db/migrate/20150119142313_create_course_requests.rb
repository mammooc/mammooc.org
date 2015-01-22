class CreateCourseRequests < ActiveRecord::Migration
  def change
    create_table :course_requests, id: :uuid do |t|
      t.datetime :date
      t.text :description
      t.references :course, type: 'uuid', index: true
      t.references :user, type: 'uuid', index: true
      t.references :group, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :course_requests, :courses
    add_foreign_key :course_requests, :users
    add_foreign_key :course_requests, :groups
  end
end
