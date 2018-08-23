# frozen_string_literal: true

class AddUpdateDateAndChangeDateInEvaluations < ActiveRecord::Migration[4.2]
  def change
    change_table(:evaluations, bulk: true) do |t|
      t.change :evaluation_helpful_rating_count, :integer, null: false, default: 0
      t.change :evaluation_rating_count, :integer, null: false, default: 0
      t.datetime :update_date
      t.remove :date
      t.datetime :creation_date
    end
  end
end
