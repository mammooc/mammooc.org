# encoding: utf-8
# frozen_string_literal: true

class ChangeTextAttributeForRecommendations < ActiveRecord::Migration
  def change
    change_column :recommendations, :text, :text
  end
end
