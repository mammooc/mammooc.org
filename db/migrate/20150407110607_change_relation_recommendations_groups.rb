class ChangeRelationRecommendationsGroups < ActiveRecord::Migration
  def change
    remove_reference :recommendations, :group
  end
end
