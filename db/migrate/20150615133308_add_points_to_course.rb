class AddPointsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :points_maximal, :float, null: true, default: nil
  end
end
