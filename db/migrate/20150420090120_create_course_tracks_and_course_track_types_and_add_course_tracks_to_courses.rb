# frozen_string_literal: true

class CreateCourseTracksAndCourseTrackTypesAndAddCourseTracksToCourses < ActiveRecord::Migration[4.2]
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

    change_table(:courses, bulk: true) do |t|
      t.remove :type_of_achievement
      t.remove :costs
      t.remove :price_currency
      t.remove :has_free_version
      t.remove :has_paid_version
    end
  end
end
