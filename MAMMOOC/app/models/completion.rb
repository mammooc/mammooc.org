class Completion < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :certificates
end
