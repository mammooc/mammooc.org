# frozen_string_literal: true

class ChangeCalculatedRatingInCourses < ActiveRecord::Migration[4.2]
  def change
    change_column(:courses, :calculated_rating, :float)
  end
end
