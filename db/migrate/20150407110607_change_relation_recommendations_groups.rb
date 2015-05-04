# -*- encoding : utf-8 -*-
class ChangeRelationRecommendationsGroups < ActiveRecord::Migration
  def change
    remove_reference :recommendations, :group
  end
end
