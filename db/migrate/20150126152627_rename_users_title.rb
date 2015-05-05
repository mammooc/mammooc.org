# -*- encoding : utf-8 -*-
class RenameUsersTitle < ActiveRecord::Migration
  def change
    rename_column :users, :title, :gender
  end
end
