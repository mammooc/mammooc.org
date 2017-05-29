# frozen_string_literal: true

class Completion < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :certificates, dependent: :destroy

  def sorted_certificates
    certificates.sort_by(&:classification)
  end
end
