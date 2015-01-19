class CreateUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups, id: :uuid do |t|
      t.boolean :is_admin
      t.references :user, type: 'uuid', index: true
      t.references :group, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :user_groups, :users
    add_foreign_key :user_groups, :groups
  end
end
