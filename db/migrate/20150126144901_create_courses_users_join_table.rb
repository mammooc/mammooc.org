# frozen_string_literal: true

class CreateCoursesUsersJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_table :courses_users, id: false do |t|
      t.uuid :course_id
      t.uuid :user_id
    end
  end
end
