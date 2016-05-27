# frozen_string_literal: true

class AddCreditPointsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :credit_points, :integer
  end
end
