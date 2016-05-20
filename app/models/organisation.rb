# frozen_string_literal: true

class Organisation < ActiveRecord::Base
  has_many :courses
end
