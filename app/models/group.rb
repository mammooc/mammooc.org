class Group < ActiveRecord::Base
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :statistics
  has_many :recommendations
  has_many :course_requests
  has_many :group_invitations
end
