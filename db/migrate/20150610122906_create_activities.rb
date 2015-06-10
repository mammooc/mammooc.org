# Migration responsible for creating a table with activities
class CreateActivities < ActiveRecord::Migration
  # Create table
  def self.up
    create_table :activities, id: :uuid do |t|
      t.belongs_to :trackable, type: 'uuid', polymorphic: true
      t.belongs_to :owner, type: 'uuid', polymorphic: true
      t.string  :key
      t.text    :parameters
      t.belongs_to :recipient, type: 'uuid', polymorphic: true

      t.timestamps
    end

    add_index :activities, [:trackable_id, :trackable_type]
    add_index :activities, [:owner_id, :owner_type]
    add_index :activities, [:recipient_id, :recipient_type]
  end
  # Drop table
  def self.down
    drop_table :activities
  end
end
