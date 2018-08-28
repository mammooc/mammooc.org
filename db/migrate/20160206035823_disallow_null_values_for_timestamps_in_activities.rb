# frozen_string_literal: true

class DisallowNullValuesForTimestampsInActivities < ActiveRecord::Migration[4.2]
  def change
    change_table(:activities, bulk: true) do |t|
      t.change :created_at, :timestamp, null: false
      t.change :updated_at, :timestamp, null: false
    end
  end
end
