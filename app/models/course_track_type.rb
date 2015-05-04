class CourseTrackType < ActiveRecord::Base
  has_many :course_tracks

  validates :title, :type_of_achievement, presence: true
end
