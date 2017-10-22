# frozen_string_literal: true

class CreateRecommendationsGroupsJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_table :groups_recommendations, id: false do |t|
      t.uuid :recommendation_id
      t.uuid :group_id
    end
  end
end
