require 'ipaddr'
module OregonDigital
  module IpGroups
    extend ActiveSupport::Concern
    def groups
      groups = super
      if current_sign_in_ip
        ip_int = IPAddr.new(current_sign_in_ip).to_i
        ip_groups = Role.joins(:ip_ranges).where('ip_start_i <= ? AND ip_end_i >= ?',ip_int, ip_int).pluck(:name)
        groups |= ip_groups
      end
      return groups
    end
  end
end