class RolesIpRangesController < ApplicationController
  load_and_authorize_resource :role
  def create
    authorize! :add_ip_range, @role
    ip_range = IpRange.new
    ip_range.ip_start = params[:ip_range_start]
    ip_range.ip_end = params[:ip_range_end]
    ip_range.role = @role
    if ip_range.save
      redirect_to role_management.role_path(@role)
    else
      redirect_to role_management.role_path(@role), :flash => {:error => "Invalid data given for IP Range"}
    end
  end
  def destroy
    authorize! :remove_ip_range, @role
    range = ::IpRange.where(:id => params[:id])
    @role.ip_ranges.delete(range)
    redirect_to role_management.role_path(@role)
  end
end