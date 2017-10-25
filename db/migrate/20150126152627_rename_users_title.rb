# frozen_string_literal: true

class RenameUsersTitle < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :title, :gender
  end
end
