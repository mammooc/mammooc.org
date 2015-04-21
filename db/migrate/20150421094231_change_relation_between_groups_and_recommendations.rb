class ChangeRelationBetweenGroupsAndRecommendations < ActiveRecord::Migration
  def change

    drop_join_table :groups, :recommendations

    add_reference :recommendations, :group, index: true, type: 'uuid'
    add_foreign_key :recommendations, :groups

  end
end
