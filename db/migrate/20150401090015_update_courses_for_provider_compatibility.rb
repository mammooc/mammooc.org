# frozen_string_literal: true

class UpdateCoursesForProviderCompatibility < ActiveRecord::Migration[4.2]
  def change
    change_table(:courses, bulk: true) do |t|
      t.change :start_date, :datetime, null: true
      t.change :end_date, :datetime, null: true
      t.string :workload
      t.remove :minimum_weekly_workload
      t.remove :maximum_weekly_workload
      t.uuid :previous_iteration_id
      t.uuid :following_iteration_id
      t.change :course_instructors, :string
      t.string :subtitle_languages

      t.remove :duration
      t.integer :calculated_duration_in_days
      t.string :provider_given_duration
    end
  end
end
