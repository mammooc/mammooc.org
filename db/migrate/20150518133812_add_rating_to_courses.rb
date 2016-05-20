# frozen_string_literal: true

class AddRatingToCourses < ActiveRecord::Migration
  def change
    add_column(:courses, :calculated_rating, :integer)
    add_column(:courses, :rating_count, :integer)
  end
end
