# -*- encoding : utf-8 -*-
class CreateCoursesUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :courses_users, id: false do |t|
      t.uuid :course_id
      t.uuid :user_id
    end
  end
end
