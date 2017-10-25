# frozen_string_literal: true

class ChangeRelationBetweenGroupsAndRecommendations < ActiveRecord::Migration[4.2]
  def change
    drop_join_table :groups, :recommendations

    add_reference :recommendations, :group, index: true, type: 'uuid'
    add_foreign_key :recommendations, :groups
  end
end
