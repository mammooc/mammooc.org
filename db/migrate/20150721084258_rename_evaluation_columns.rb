# encoding: utf-8
# frozen_string_literal: true

class RenameEvaluationColumns < ActiveRecord::Migration
  def change
    rename_column :evaluations, :evaluation_helpful_rating_count, :positive_feedback_count
    rename_column :evaluations, :evaluation_rating_count, :total_feedback_count
  end
end
