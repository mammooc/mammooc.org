# frozen_string_literal: true
class AddUnsubscribedNewsletterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unsubscribed_newsletter, :boolean, null: true, default: nil
  end
end
