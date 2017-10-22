# frozen_string_literal: true

class AddRatingToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column(:courses, :calculated_rating, :integer)
    add_column(:courses, :rating_count, :integer)
  end
end
