# frozen_string_literal: true

class DeleteUsersPassword < ActiveRecord::Migration
  def change
    remove_column :users, :password
  end
end
