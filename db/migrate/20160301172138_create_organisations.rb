class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations, id: :uuid do |t|
      t.string :name
      t.string :url

      t.timestamps null: false
    end

    remove_column :courses, :organisation

    add_reference :courses, :organisation, type: 'uuid', index: true, foreign_key: true
  end
end
