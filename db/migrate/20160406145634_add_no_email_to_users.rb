# encoding: utf-8
# frozen_string_literal: true

class AddNoEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :no_email, :boolean, default: false
  end
end
