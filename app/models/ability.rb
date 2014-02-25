class Ability
  include Hydra::Ability
  self.ability_logic += [:role_permissions]
  self.ability_logic += [:review_permissions]
  self.ability_logic += [:ingest_permissions]

  def role_permissions
    if current_user.admin?
      can [:create, :show, :edit, :destroy, :add_user, :remove_user, :index, :add_ip_range, :remove_ip_range], Role
    end
  end

  def review_permissions
    can [:review], GenericAsset if current_user.admin?
  end

  def ingest_permissions
    # Forcibly deny ingest and edit permissions to override built-in Hydra rules
    cannot [:ingest, :edit], GenericAsset

    if current_user.submitter? || current_user.archivist? || current_user.admin?
      can :ingest, GenericAsset
    end

    if current_user.archivist? || current_user.admin?
      can :edit, GenericAsset
    end
  end
end
