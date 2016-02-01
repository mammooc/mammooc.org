# encoding: utf-8
# frozen_string_literal: true

class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates, id: :uuid do |t|
      t.string :title
      t.string :file_id
      t.references :completion, type: 'uuid', index: true

      t.timestamps null: false
    end
    add_foreign_key :certificates, :completions
  end
end
