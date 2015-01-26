class CreateRecommendationsUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :recommendations_users, id: false do |t|
      t.uuid :recommendation_id
      t.uuid :user_id
    end
  end
end
