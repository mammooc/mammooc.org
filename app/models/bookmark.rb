# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :course
  include PublicActivity::Common
end
