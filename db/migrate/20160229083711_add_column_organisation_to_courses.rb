# encoding: utf-8
# frozen_string_literal: true

class AddColumnOrganisationToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :organisation, :string, null: true, default: nil
  end
end
