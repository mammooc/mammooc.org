# encoding: utf-8
# frozen_string_literal: true

class UpdateColumnsOfCourses < ActiveRecord::Migration
  def change
    remove_column(:courses, :workload, :string)
    add_column(:courses, :minimum_weekly_workload, :float)
    add_column(:courses, :maximum_weekly_workload, :float)
    add_column(:courses, :price_currency, :string)

    remove_column(:courses, :categories, :string)
    add_column(:courses, :categories, :string, array: true)
    remove_column(:courses, :requirements, :string)
    add_column(:courses, :requirements, :string, array: true)
    remove_column(:courses, :course_instructor, :string)
    add_column(:courses, :course_instructors, :string, array: true)

    change_column(:courses, :provider_course_id, :string, null: false)
    change_column(:courses, :name, :string, null: false)
    change_column(:courses, :url, :string, null: false)
    change_column(:courses, :start_date, :datetime, null: false)
    change_column(:courses, :end_date, :datetime, null: false)
    change_column(:courses, :mooc_provider_id, :uuid, null: false)

    add_column(:courses, :description, :text)
    change_column(:courses, :credit_points, :float)
    change_column(:courses, :duration, 'integer USING CAST(duration AS integer)')
    change_column(:courses, :costs, 'float USING CAST(costs AS float)')
  end
end
