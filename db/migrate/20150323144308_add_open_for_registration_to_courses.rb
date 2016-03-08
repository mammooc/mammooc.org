# encoding: utf-8
# frozen_string_literal: true

class AddOpenForRegistrationToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :open_for_registration, :boolean
  end
end
