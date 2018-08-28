# frozen_string_literal: true

class AddAttributesForNewsletter < ActiveRecord::Migration[4.2]
  def change
    change_table(:users, bulk: true) do |t|
      t.datetime :last_newsletter_send_at, null: true, default: nil
      t.integer :newsletter_interval, null: true, default: nil
    end
  end
end
