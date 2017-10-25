# frozen_string_literal: true

class AddColumnOrganisationToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :organisation, :string, null: true, default: nil
  end
end
