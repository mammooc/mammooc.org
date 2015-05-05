# -*- encoding : utf-8 -*-
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :password
      t.string :profile_image_id
      t.json :email_settings
      t.text :about_me
      t.timestamps null: false
    end
  end
end
