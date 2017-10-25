# frozen_string_literal: true

class AddAttributeTextToRecommendations < ActiveRecord::Migration[4.2]
  def change
    add_column :recommendations, :text, :string
  end
end
