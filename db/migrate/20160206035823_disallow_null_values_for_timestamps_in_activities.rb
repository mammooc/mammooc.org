# frozen_string_literal: true

class DisallowNullValuesForTimestampsInActivities < ActiveRecord::Migration[4.2]
  def change
    change_column_null :activities, :created_at, false
    change_column_null :activities, :updated_at, false
  end
end
