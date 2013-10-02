class Ability
  include Hydra::Ability
  self.ability_logic += [:role_permissions]
  def role_permissions
    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index], Role
    end
  end
end
