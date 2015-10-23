class UserDate < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  belongs_to :mooc_provider
end
