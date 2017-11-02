# frozen_string_literal: true

class UserCourse < ApplicationRecord
  belongs_to :user
  belongs_to :course
end
