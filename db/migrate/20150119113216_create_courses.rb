# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[4.2]
  def change
    create_table :courses, id: :uuid do |t|
      t.string :name
      t.string :url
      t.string :course_instructor
      t.text :abstract
      t.string :language
      t.string :imageId
      t.string :videoId
      t.datetime :start_date
      t.datetime :end_date
      t.string :duration
      t.string :costs
      t.string :type_of_achievement
      t.string :categories
      t.string :difficulty
      t.string :requirements
      t.string :workload
      t.integer :provider_course_id
      t.references :mooc_provider, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :courses, :mooc_providers
  end
end
