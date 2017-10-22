# frozen_string_literal: true

class RemoveMoocProviderIdFromUserDate < ActiveRecord::Migration[4.2]
  def change
    remove_column :user_dates, :mooc_provider_id, :uuid
  end
end
