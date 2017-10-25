# frozen_string_literal: true

class RenameEvaluationColumns < ActiveRecord::Migration[4.2]
  def change
    rename_column :evaluations, :evaluation_helpful_rating_count, :positive_feedback_count
    rename_column :evaluations, :evaluation_rating_count, :total_feedback_count
  end
end
