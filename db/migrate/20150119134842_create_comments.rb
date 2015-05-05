# -*- encoding : utf-8 -*-
class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments, id: :uuid do |t|
      t.datetime :date
      t.text :content
      t.references :user, type: 'uuid', index: true
      t.references :recommendation, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :comments, :users
    add_foreign_key :comments, :recommendations
  end
end
