class CourseAssignment < ActiveRecord::Base
  belongs_to :course
  has_many :user_assignments
end
