# encoding: utf-8
# frozen_string_literal: true

class ChangeIsAdminDefaultToFalse < ActiveRecord::Migration
  def change
    change_column_default :user_groups, :is_admin, false
  end
end
