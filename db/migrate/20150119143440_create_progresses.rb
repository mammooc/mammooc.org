class CreateProgresses < ActiveRecord::Migration
  def change
    create_table :progresses, id: :uuid do |t|
      t.float :percentage
      t.string :permissions, array: true
      t.references :course, type:'uuid', index: true
      t.references :user, type:'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :progresses, :courses
    add_foreign_key :progresses, :users
  end
end
