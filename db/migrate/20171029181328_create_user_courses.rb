# frozen_string_literal: true

class CreateUserCourses < ActiveRecord::Migration[5.1]
  def change
    rename_table :courses_users, :user_courses

    add_column :user_courses, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    add_column :user_courses, :provider_id, :string, null: true, default: nil
    add_column :user_courses, :created_at, :datetime, null: false, default: -> { 'now()' }
    add_column :user_courses, :updated_at, :datetime, null: false, default: -> { 'now()' }

    add_index :user_courses, :user_id
    add_index :user_courses, :course_id

    add_foreign_key :user_courses, :users, foreign_key: true
    add_foreign_key :user_courses, :courses, foreign_key: true

    execute 'ALTER TABLE user_courses ADD PRIMARY KEY (id);'
  end
end
