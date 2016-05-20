# frozen_string_literal: true

class Bookmark < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  include PublicActivity::Common
end
