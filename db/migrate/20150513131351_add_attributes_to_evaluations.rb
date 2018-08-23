# frozen_string_literal: true

class AddAttributesToEvaluations < ActiveRecord::Migration[4.2]
  def change
    change_table(:evaluations, bulk: true) do |t|
      t.integer :course_status
      t.boolean :rated_anonymously
      t.integer :evaluation_rating_count
      t.integer :evaluation_helpful_rating_count
      t.remove :title
    end
  end
end
