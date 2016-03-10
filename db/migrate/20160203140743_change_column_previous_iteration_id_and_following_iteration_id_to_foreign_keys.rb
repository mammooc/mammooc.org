# encoding: utf-8
# frozen_string_literal: true

class ChangeColumnPreviousIterationIdAndFollowingIterationIdToForeignKeys < ActiveRecord::Migration
  def change
    remove_column :courses, :previous_iteration_id
    remove_column :courses, :following_iteration_id

    add_reference :courses, :previous_iteration, references: :courses, index: true, type: 'uuid'
    add_foreign_key :courses, :courses, column: :previous_iteration_id

    add_reference :courses, :following_iteration, references: :courses, index: true, type: 'uuid'
    add_foreign_key :courses, :courses, column: :following_iteration_id
  end
end
