# frozen_string_literal: true

class AddCustomFieldsToActivities < ActiveRecord::Migration[4.2]
  def change
    change_table :activities do |t|
      t.uuid :user_ids, array: true
      t.uuid :group_ids, array: true
    end
  end
end
