# -*- encoding : utf-8 -*-
class UserAssignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  belongs_to :course_assignment
end
