# frozen_string_literal: true

class RenameGroupImageId < ActiveRecord::Migration[4.2]
  def change
    rename_column :groups, :imageId, :image_id
  end
end
