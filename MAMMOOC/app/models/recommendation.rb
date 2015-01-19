class Recommendation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group, null: true
  belongs_to :course
  has_many :comments
  has_and_belongs_to_many :users
end
