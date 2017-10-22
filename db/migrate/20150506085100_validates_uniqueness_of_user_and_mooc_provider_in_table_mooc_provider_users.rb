# frozen_string_literal: true

class ValidatesUniquenessOfUserAndMoocProviderInTableMoocProviderUsers < ActiveRecord::Migration[4.2]
  def change
    add_index :mooc_provider_users, %w[user_id mooc_provider_id], unique: true
  end
end
