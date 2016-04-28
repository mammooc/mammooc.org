# encoding: utf-8
# frozen_string_literal: true

class AddColumnUsedToGroupInvitations < ActiveRecord::Migration
  def change
    add_column :group_invitations, :used, :boolean, default: false
  end
end
