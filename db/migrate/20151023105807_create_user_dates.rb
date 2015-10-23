class CreateUserDates < ActiveRecord::Migration
  def change
    create_table :user_dates do |t|
      t.references :user, index: true, foreign_key: true
      t.references :course, index: true, foreign_key: true
      t.references :mooc_provider, index: true, foreign_key: true
      t.datetime :date
      t.string :title
      t.string :kind
      t.boolean :relevant
      t.string :ressource_id_from_provider

      t.timestamps null: false
    end
  end
end
