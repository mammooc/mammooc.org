# frozen_string_literal: true

class AddCreditPointsToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :credit_points, :integer
  end
end
