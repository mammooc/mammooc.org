# encoding: utf-8
# frozen_string_literal: true

class ChangeCalculatedRatingInCourses < ActiveRecord::Migration
  def change
    change_column(:courses, :calculated_rating, :float)
  end
end
