class AddNewsletterLanguageToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :newsletter_language, :string, default: 'en'
  end
end
