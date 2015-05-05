# -*- encoding : utf-8 -*-
class AllowNullValueForGroupIdInGroupInvitations < ActiveRecord::Migration
  def change
    change_column_null :group_invitations, :group_id, true
  end
end
