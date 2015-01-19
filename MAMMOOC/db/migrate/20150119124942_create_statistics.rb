class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics, id: :uuid do |t|
      t.string :name
      t.text :result
      t.references :group, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :statistics, :groups
  end
end
