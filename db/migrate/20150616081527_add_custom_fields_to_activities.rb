# encoding: utf-8
# frozen_string_literal: true

class AddCustomFieldsToActivities < ActiveRecord::Migration
  def change
    change_table :activities do |t|
      t.uuid :user_ids, array: true
      t.uuid :group_ids, array: true
    end
  end
end
