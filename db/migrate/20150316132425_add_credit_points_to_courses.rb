# -*- encoding : utf-8 -*-
class AddCreditPointsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :credit_points, :integer
  end
end
