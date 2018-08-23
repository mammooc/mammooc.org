# frozen_string_literal: true

class CreateUserCourses < ActiveRecord::Migration[5.1]
  def change
    rename_table :courses_users, :user_courses

    change_table(:user_courses, bulk: true) do |t|
      t.uuid :id, null: false, default: 'uuid_generate_v4()'
      t.string :provider_id, null: true, default: nil
      t.datetime :created_at, null: false, default: -> { 'now()' }
      t.datetime :updated_at, null: false, default: -> { 'now()' }

      t.index :user_id
      t.index :course_id
    end

    add_foreign_key :user_courses, :users, foreign_key: true
    add_foreign_key :user_courses, :courses, foreign_key: true

    execute 'ALTER TABLE user_courses ADD PRIMARY KEY (id);'
  end
end
