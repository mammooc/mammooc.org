class RemoveDateColumsFromEvaluations < ActiveRecord::Migration
  def change
    remove_column :evaluations, :creation_date
    remove_column :evaluations, :update_date
  end
end
