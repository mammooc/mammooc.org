class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals, id: :uuid do |t|
      t.datetime :date
      t.boolean :is_approved
      t.string :description
      t.references :user, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :approvals, :users
  end
end
