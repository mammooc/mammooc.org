class AddUpdateDateAndChangeDateInEvaluations < ActiveRecord::Migration
  def change
    change_column(:evaluations, :evaluation_helpful_rating_count, :integer, null: false, default: 0)
    change_column(:evaluations, :evaluation_rating_count, :integer, null: false, default: 0)
    add_column(:evaluations, :update_date, :datetime)
    remove_column(:evaluations, :date, :datetime)
    add_column(:evaluations, :creation_date, :datetime)
  end
end
