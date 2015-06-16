# -*- encoding : utf-8 -*-
class Completion < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :certificates, dependent: :destroy

  def sorted_certificates
    self.certificates.sort_by do |certificate|
      certificate.classification
    end
  end
end
