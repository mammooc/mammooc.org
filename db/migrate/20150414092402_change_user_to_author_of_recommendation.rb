# encoding: utf-8
# frozen_string_literal: true

class ChangeUserToAuthorOfRecommendation < ActiveRecord::Migration
  def change
    remove_reference :recommendations, :user

    add_reference :recommendations, :author, references: :users, index: true, type: 'uuid'
    add_foreign_key :recommendations, :users, column: :author_id
  end
end
