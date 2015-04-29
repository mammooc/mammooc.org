class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :first_name, :last_name, :profile_image_id, presence: true
  has_many :emails
  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :recommendations
  has_and_belongs_to_many :recommendations
  has_many :comments
  has_many :mooc_provider_users
  has_many :mooc_providers, through: :mooc_provider_users
  has_many :completions
  has_and_belongs_to_many :courses
  has_many :course_requests
  has_many :approvals
  has_many :progresses
  has_many :bookmarks
  has_many :evaluations
  has_many :user_assignments
end
