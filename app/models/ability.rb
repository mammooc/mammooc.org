# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    # Groups
    can [:create, :join], Group
    can [:read, :members, :admins, :leave, :condition_for_changing_member_status, :recommendations, :statistics], Group do |group|
      user.groups.include? group
    end
    can [:update, :destroy, :invite_group_members, :add_administrator, :demote_administrator, :remove_group_member, :all_members_to_administrators, :synchronize_courses], Group do |group|
      UserGroup.where(user_id: user.id, group_id: group.id, is_admin: true).any?
    end

    # Recommendations
    can [:index], Recommendation

    can [:create], Recommendation do
      user.groups.any?
    end

    can [:delete_user_from_recommendation], Recommendation do |recommendation|
      recommendation.users.include? user
    end

    can [:delete_group_recommendation], Recommendation do |recommendation|
      UserGroup.where(user_id: user.id, group_id: recommendation.group.id, is_admin: true).any?
    end

    # Users
    cannot [:create, :show, :update, :destroy, :finish_signup], User
    can [:show, :update, :destroy, :finish_signup], User do |checked_user|
      user_is_able = checked_user.id == user.id
      user.groups.each do |group|
        user_is_able = true if group.users.include? checked_user
        break if user_is_able
      end
      user_is_able
    end
  end
end
