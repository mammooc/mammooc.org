class Group < ActiveRecord::Base
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :statistics
  has_many :recommendations
  has_many :course_requests
  has_many :group_invitations
  validates :image_id, presence: true

  def destroy
    UserGroup.destroy_all(group_id: self.id)
    GroupInvitation.where(group_id: self.id).update_all(group_id: nil)
    super
  end
end
