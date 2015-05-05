# -*- encoding : utf-8 -*-
class AddColumnUsedToGroupInvitations < ActiveRecord::Migration
  def change
    add_column :group_invitations, :used, :boolean, default: false
  end
end
