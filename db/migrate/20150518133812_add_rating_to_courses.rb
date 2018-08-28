# frozen_string_literal: true

class AddRatingToCourses < ActiveRecord::Migration[4.2]
  def change
    change_table(:courses, bulk: true) do |t|
      t.integer :calculated_rating
      t.integer :rating_count
    end
  end
end
