# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable
  validates :first_name, :last_name, :profile_image_id, presence: true
  has_many :emails, dependent: :destroy
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :recommendations
  has_and_belongs_to_many :recommendations
  has_many :comments
  has_many :mooc_provider_users, dependent: :destroy
  has_many :mooc_providers, through: :mooc_provider_users
  has_many :completions
  has_and_belongs_to_many :courses
  has_many :course_requests
  has_many :approvals
  has_many :progresses
  has_many :bookmarks
  has_many :evaluations
  has_many :user_assignments
  before_destroy :handle_group_memberships, prepend: true

  def handle_group_memberships
    groups.each do |group|
      if group.users.count > 1
        if UserGroup.find_by(group: group, user: self).is_admin
          if UserGroup.where(group: group, is_admin: true).count == 1
            return false
          end
        end
      else
        group.destroy
      end
    end
  end


  def common_groups_with_user(other_user)
    (other_user.groups.to_a.collect {|g| self.groups.include?(g) ? g : nil}).compact()
  end

end

