# frozen_string_literal: true

class AddPointsToCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :points_maximal, :float, null: true, default: nil
  end
end
