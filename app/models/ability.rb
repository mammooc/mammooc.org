class Ability
  include CanCan::Ability

  def initialize(user)
    can [:create, :join], Group
    can [:read, :members, :admins, :leave, :condition_for_changing_member_status], Group do |group|
      user.groups.include? group
    end
    can [:update, :destroy, :invite_group_members, :add_administrator, :demote_administrator, :remove_group_member, :all_members_to_administrators], Group do |group|
      usergroup = UserGroup.find_by(user_id: user.id, group_id: group.id)
      if usergroup
        usergroup.is_admin == true
      else
        false
      end
    end
  end
end