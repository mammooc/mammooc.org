# -*- encoding : utf-8 -*-
class RenameGroupImageId < ActiveRecord::Migration
  def change
    rename_column :groups, :imageId, :image_id
  end
end
