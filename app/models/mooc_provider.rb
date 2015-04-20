class MoocProvider < ActiveRecord::Base
  has_many :courses
  has_many :users, through: :mooc_provider_users
  validates_uniqueness_of :name

end
