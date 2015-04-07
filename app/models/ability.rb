class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Group do |group|
      user.groups.include? group
    end
  end
end