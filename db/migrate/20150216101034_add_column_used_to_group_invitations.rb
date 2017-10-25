# frozen_string_literal: true

class AddColumnUsedToGroupInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :group_invitations, :used, :boolean, default: false
  end
end
