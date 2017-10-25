# frozen_string_literal: true

class AllowNullValueForGroupIdInGroupInvitations < ActiveRecord::Migration[4.2]
  def change
    change_column_null :group_invitations, :group_id, true
  end
end
