class AddAttributesToEvaluations < ActiveRecord::Migration
  def change
    add_column(:evaluations, :course_status, :integer)
    add_column(:evaluations, :rated_anonymously, :boolean)
    add_column(:evaluations, :evaluation_rating_count, :integer)
    add_column(:evaluations, :evaluation_helpful_rating_count, :integer)
    remove_column(:evaluations, :title)
  end
end
