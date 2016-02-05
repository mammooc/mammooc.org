# encoding: utf-8
# frozen_string_literal: true

class ChangeRelationRecommendationsGroups < ActiveRecord::Migration
  def change
    remove_reference :recommendations, :group
  end
end
