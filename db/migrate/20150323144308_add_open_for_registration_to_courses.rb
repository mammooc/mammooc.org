# -*- encoding : utf-8 -*-
class AddOpenForRegistrationToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :open_for_registration, :boolean
  end
end
