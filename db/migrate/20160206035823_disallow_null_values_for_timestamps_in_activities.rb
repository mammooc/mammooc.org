# encoding: utf-8
# frozen_string_literal: true

class DisallowNullValuesForTimestampsInActivities < ActiveRecord::Migration
  def change
    change_column_null :activities, :created_at, false
    change_column_null :activities, :updated_at, false
  end
end
