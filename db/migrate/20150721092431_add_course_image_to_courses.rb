# frozen_string_literal: true

class AddCourseImageToCourses < ActiveRecord::Migration[4.2]
  def up
    remove_column :courses, :imageId
    add_attachment :courses, :course_image
  end

  def down
    remove_attachment :courses, :course_image
    add_column :courses, :imageId, :string
  end
end
