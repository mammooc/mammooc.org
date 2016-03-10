# encoding: utf-8
# frozen_string_literal: true

class ValidatesUniquenessOfUserAndMoocProviderInTableMoocProviderUsers < ActiveRecord::Migration
  def change
    add_index :mooc_provider_users, %w(user_id mooc_provider_id), unique: true
  end
end
