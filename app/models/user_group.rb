class UserGroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  def self.set_is_admin(group_id, user_id, is_admin)
    user_group = UserGroup.where(group_id: group_id, user_id: user_id).first
    user_group.is_admin = is_admin
    user_group.save
  end

end
