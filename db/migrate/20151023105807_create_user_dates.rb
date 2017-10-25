# frozen_string_literal: true

class CreateUserDates < ActiveRecord::Migration[4.2]
  def change
    create_table :user_dates, id: :uuid do |t|
      t.references :user, type: :uuid, index: true, foreign_key: true
      t.references :course, type: :uuid, index: true, foreign_key: true
      t.references :mooc_provider, type: :uuid, index: true, foreign_key: true
      t.datetime :date
      t.string :title
      t.string :kind
      t.boolean :relevant
      t.string :ressource_id_from_provider

      t.timestamps null: false
    end
  end
end
