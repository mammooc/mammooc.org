# -*- encoding : utf-8 -*-
class Evaluation < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  after_save :updateCourseRatingAndCount

  def updateCourseRatingAndCount
    puts rating
    puts course_id
    Course.updateCourseRatingAttributes course_id
  end
end
