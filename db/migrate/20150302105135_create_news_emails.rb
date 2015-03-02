class CreateNewsEmails < ActiveRecord::Migration
  def change
    create_table :news_emails do |t|
      t.string :email

      t.timestamps null: false
    end
  end
end
