class ChangeProfileImageIdDatatype < ActiveRecord::Migration
  def self.up
    remove_column :users, :profile_image_id
    add_attachment :users, :profile_image
  end

  def self.down
    add_column :users, :profile_image_id, :string
    remove_attachment :users, :profile_image
  end
end
