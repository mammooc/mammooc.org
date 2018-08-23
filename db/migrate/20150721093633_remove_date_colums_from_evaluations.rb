# frozen_string_literal: true

class RemoveDateColumsFromEvaluations < ActiveRecord::Migration[4.2]
  def change
    change_table(:evaluations, bulk: true) do |t|
      t.remove :creation_date
      t.remove :update_date
    end
  end
end
