# encoding: utf-8
# frozen_string_literal: true

class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks, id: :uuid do |t|
      t.references :user, type: 'uuid', index: true
      t.references :course, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :bookmarks, :users
    add_foreign_key :bookmarks, :courses
  end
end
