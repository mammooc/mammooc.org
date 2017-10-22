# frozen_string_literal: true

class CreateRecommendationsUsersJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_table :recommendations_users, id: false do |t|
      t.uuid :recommendation_id
      t.uuid :user_id
    end
  end
end
