class RolesIpRangesController < ApplicationController
  load_and_authorize_resource :role

  def create
    authorize! :add_ip_range, @role
    IpRangeCreator.call(@role, params, self)
  end

  def create_success(ip_range, role)
    redirect_to role_management.role_path(role)
  end

  def create_failure(ip_range, role)
    redirect_to role_management.role_path(role), :flash => {:error => "Invalid data given for IP Range"}
  end

  def destroy
    authorize! :remove_ip_range, @role
    range = ::IpRange.where(:id => params[:id])
    @role.ip_ranges.delete(range)
    redirect_to role_management.role_path(@role)
  end
end
