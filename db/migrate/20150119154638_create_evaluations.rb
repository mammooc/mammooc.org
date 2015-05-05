# -*- encoding : utf-8 -*-
class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations, id: :uuid do |t|
      t.string :title
      t.float :rating
      t.boolean :is_verified
      t.text :description
      t.datetime :date
      t.references :user, type: 'uuid', index: true
      t.references :course, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :evaluations, :users
    add_foreign_key :evaluations, :courses
  end
end
