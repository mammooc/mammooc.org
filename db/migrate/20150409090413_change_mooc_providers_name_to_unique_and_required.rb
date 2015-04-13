class ChangeMoocProvidersNameToUniqueAndRequired < ActiveRecord::Migration
  def change
    add_index :mooc_providers, :name, unique: true
    change_column(:mooc_providers, :name, :string, null: false)
  end
end
