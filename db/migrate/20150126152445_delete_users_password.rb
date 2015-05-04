# -*- encoding : utf-8 -*-
class DeleteUsersPassword < ActiveRecord::Migration
  def change
    remove_column :users, :password
  end
end
