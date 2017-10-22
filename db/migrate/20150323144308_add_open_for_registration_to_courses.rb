# frozen_string_literal: true

class AddOpenForRegistrationToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :open_for_registration, :boolean
  end
end
