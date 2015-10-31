class AddColumnForUserDatesTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :token_for_user_dates, :string
  end
end
