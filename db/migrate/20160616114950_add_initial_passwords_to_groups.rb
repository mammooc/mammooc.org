# encoding: utf-8
# frozen_string_literal: true

class AddInitialPasswordsToGroups < ActiveRecord::Migration
  def up
    execute "create extension hstore"
    add_column :groups, :initial_passwords, :hstore
  end
  
  def down
    remove_column :groups, :initial_passwords
  end
end
