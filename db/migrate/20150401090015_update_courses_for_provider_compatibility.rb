class UpdateCoursesForProviderCompatibility < ActiveRecord::Migration
  def change
    change_column(:courses, :start_date, :datetime, null: true)
    change_column(:courses, :end_date, :datetime, null: true)
    add_column(:courses, :workload, :string)
    remove_column(:courses, :minimum_weekly_workload, :float)
    remove_column(:courses, :maximum_weekly_workload, :float)
    add_column(:courses, :previous_iteration_id, :uuid)
    add_column(:courses, :following_iteration_id, :uuid)
    change_column(:courses, :course_instructors, :string)
    add_column(:courses, :subtitle_languages, :string)

    remove_column(:courses, :duration, :integer)
    add_column(:courses, :calculated_duration_in_days, :integer)
    add_column(:courses, :provider_given_duration, :string)


  end
end
