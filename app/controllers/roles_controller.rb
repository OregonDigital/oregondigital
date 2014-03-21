class RolesController < ApplicationController
  before_filter :load_role, :only => [:create]
  include Hydra::RoleManagement::RolesBehavior

  def load_role
    @role = Role.new(role_params)
  end
end
