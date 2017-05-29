# frozen_string_literal: true

class Organisation < ApplicationRecord
  has_many :courses, dependent: :destroy
end
