# frozen_string_literal: true

class MoveCreditPointsToCourseTrack < ActiveRecord::Migration[4.2]
  def change
    remove_column :courses, :credit_points
    add_column :course_tracks, :credit_points, :float
  end
end
