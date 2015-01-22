class CreateCourseResults < ActiveRecord::Migration
  def change
    create_table :course_results, id: :uuid do |t|
      t.float :maximum_score
      t.float :average_score
      t.float :best_score

      t.timestamps null: false
    end
  end
end
