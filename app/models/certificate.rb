# frozen_string_literal: true

class Certificate < ActiveRecord::Base
  belongs_to :completion

  def classification
    case document_type
      when 'confirmation_of_participation'
        0
      when 'record_of_achievement'
        1
      when 'certificate'
        2
      else
        3
    end
  end
end
