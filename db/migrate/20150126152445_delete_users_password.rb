# frozen_string_literal: true

class DeleteUsersPassword < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :password
  end
end
