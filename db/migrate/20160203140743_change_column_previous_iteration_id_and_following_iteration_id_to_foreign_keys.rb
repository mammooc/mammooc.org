# frozen_string_literal: true

class ChangeColumnPreviousIterationIdAndFollowingIterationIdToForeignKeys < ActiveRecord::Migration[4.2]
  def change
    change_table(:courses, bulk: true) do |t|
      t.remove :previous_iteration_id
      t.remove :following_iteration_id
      t.references :previous_iteration, references: :courses, index: true, type: 'uuid'
      t.references :following_iteration, references: :courses, index: true, type: 'uuid'
    end

    add_foreign_key :courses, :courses, column: :previous_iteration_id
    add_foreign_key :courses, :courses, column: :following_iteration_id
  end
end
