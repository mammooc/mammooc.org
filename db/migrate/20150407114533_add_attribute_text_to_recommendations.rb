class AddAttributeTextToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :text, :string
  end
end
