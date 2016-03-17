# encoding: utf-8
# frozen_string_literal: true

class Completion < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :certificates, dependent: :destroy

  def sorted_certificates
    certificates.sort_by(&:classification)
  end
end
