# frozen_string_literal: true

class ChangeTextAttributeForRecommendations < ActiveRecord::Migration[4.2]
  def change
    change_column :recommendations, :text, :text
  end
end
