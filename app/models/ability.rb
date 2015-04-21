class Ability
  include CanCan::Ability

  def initialize(user)
    #Groups
    can [:create, :join], Group
    can [:read, :members, :admins, :leave, :condition_for_changing_member_status, :recommendations], Group do |group|
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

    #Recommendations
    can [:create], Recommendation do
      !user.groups.empty?
    end
    can [:delete], Recommendation do |recommendation|
      is_admin = false
      (recommendation.groups & user.groups).each do |group|
        unless UserGroup.where(group_id: group.id, user_id: user.id, is_admin: true).empty?
          is_admin = true
        end
      end
      (recommendation.users.include? user) || is_admin
    end
    can [:index], Recommendation

  end
end
