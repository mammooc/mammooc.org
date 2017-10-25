# frozen_string_literal: true

class AddProviderIdColumnToCompletions < ActiveRecord::Migration[5.1]
  def change
    add_column :completions, :provider_id, :string
  end
end
