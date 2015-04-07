class ChangeTextAttributeForRecommendations < ActiveRecord::Migration
  def change
    change_column :recommendations, :text, :text
  end
end
