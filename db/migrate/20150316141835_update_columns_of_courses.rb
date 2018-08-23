# frozen_string_literal: true

class UpdateColumnsOfCourses < ActiveRecord::Migration[4.2]
  def change
    change_table(:courses, bulk: true) do |t|
      t.remove :workload
      t.float :minimum_weekly_workload
      t.float :maximum_weekly_workload
      t.string :price_currency

      t.remove :categories
      t.string :categories, array: true
      t.remove :requirements
      t.string :requirements, array: true
      t.remove :course_instructor
      t.string :course_instructors, array: true

      t.change :provider_course_id, :string, null: false
      t.change :name, :string, null: false
      t.change :url, :string, null: false
      t.change :start_date, :datetime, null: false
      t.change :end_date, :datetime, null: false
      t.change :mooc_provider_id, :uuid, null: false

      t.text :description
      t.change :credit_points, :float
      t.change :duration, 'integer USING CAST(duration AS integer)'
      t.change :costs, 'float USING CAST(costs AS float)'
    end
  end
end
