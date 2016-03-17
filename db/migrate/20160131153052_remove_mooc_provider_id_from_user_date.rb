# encoding: utf-8
# frozen_string_literal: true

class RemoveMoocProviderIdFromUserDate < ActiveRecord::Migration
  def change
    remove_column :user_dates, :mooc_provider_id, :uuid
  end
end
