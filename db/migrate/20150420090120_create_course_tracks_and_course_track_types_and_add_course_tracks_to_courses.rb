# encoding: utf-8
# frozen_string_literal: true

class CreateCourseTracksAndCourseTrackTypesAndAddCourseTracksToCourses < ActiveRecord::Migration
  def change
    create_table :course_track_types, id: :uuid do |t|
      t.string :type_of_achievement, null: false
      t.string :title, null: false
      t.text :description
    end

    create_table :course_tracks, id: :uuid do |t|
      t.float :costs
      t.string :costs_currency
      t.references :course_track_type, type: 'uuid', index: true
      t.references :course, type: 'uuid', index: true
    end

    add_foreign_key :course_tracks, :course_track_types
    add_foreign_key :course_tracks, :courses

    remove_column :courses, :type_of_achievement
    remove_column :courses, :costs
    remove_column :courses, :price_currency
    remove_column :courses, :has_free_version
    remove_column :courses, :has_paid_version
  end
end
