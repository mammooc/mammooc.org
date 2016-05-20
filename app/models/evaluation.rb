# frozen_string_literal: true

class Evaluation < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  after_save :update_course_rating_and_count, if: :rating_changed?
  after_destroy :update_course_rating_and_count
  enum course_status: [:aborted, :enrolled, :finished]

  def update_course_rating_and_count
    Course.update_course_rating_attributes course_id
  end
end
