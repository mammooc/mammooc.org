# frozen_string_literal: true

class ChangeGroupImageIdDatatype < ActiveRecord::Migration
  def self.up
    remove_column :groups, :image_id
    add_attachment :groups, :image
  end

  def self.down
    add_column :groups, :image_id, :string
    remove_attachment :groups, :image
  end
end
