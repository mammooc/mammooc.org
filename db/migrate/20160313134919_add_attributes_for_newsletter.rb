# encoding: utf-8
# frozen_string_literal: true
class AddAttributesForNewsletter < ActiveRecord::Migration
  def change
    add_column :users, :last_newsletter_send_at, :datetime, null: true, default: nil
    add_column :users, :newsletter_interval, :integer, null: true, default: nil
  end
end
