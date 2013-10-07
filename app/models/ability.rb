class Ability
  include Hydra::Ability
  self.ability_logic += [:role_permissions]
  def role_permissions
    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :add_ip_range, :remove_ip_range], Role
    end
  end
end
