# -*- encoding : utf-8 -*-
class Evaluation < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  after_save :updateCourseRatingAndCount

  def updateCourseRatingAndCount

  end
end
