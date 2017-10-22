# frozen_string_literal: true

class AddColumnForUserDatesTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :token_for_user_dates, :string
  end
end
