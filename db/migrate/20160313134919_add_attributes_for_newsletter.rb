# frozen_string_literal: true

class AddAttributesForNewsletter < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_newsletter_send_at, :datetime, null: true, default: nil
    add_column :users, :newsletter_interval, :integer, null: true, default: nil
  end
end
