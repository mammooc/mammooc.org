# frozen_string_literal: true

class ChangeRelationRecommendationsGroups < ActiveRecord::Migration[4.2]
  def change
    remove_reference :recommendations, :group
  end
end
