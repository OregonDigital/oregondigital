require 'ipaddr'
class IpRange < ActiveRecord::Base
  validates :ip_start, :ip_end, :ip_start_i, :ip_end_i, :role,  :presence => true
  validate :ip_start_is_ip
  validate :ip_end_is_ip
  validate :ip_start_less_than_end
  belongs_to :role
  def ip_start=(value)
    set_integer_ip(:ip_start_i, value)
    super
  end
  def ip_end=(value)
    set_integer_ip(:ip_end_i, value)
    super
  end
  def ip_start_i=(value)
    raise "This should only be set automatically by setting ip_start"
  end
  def ip_end_i=(value)
    raise "This should only be set automatically by setting ip_end"
  end

  private

  def set_integer_ip(key, value)
    begin
      ip = IPAddr.new(value)
      write_attribute(key, ip.to_i)
    rescue
      return false
    end
    true
  end

  def ip_start_is_ip
    errors.add(:ip_start, "must be a valid IP address") unless is_ip?(ip_start)
  end

  def ip_end_is_ip
    errors.add(:ip_end, "must be a valid IP address") unless is_ip?(ip_end)
  end

  def ip_start_less_than_end
    if ip_start_i && ip_end_i
      errors.add(:ip_start, "must be less than or equal to IP End") unless ip_start_i <= ip_end_i
    end
  end

  def is_ip?(value)
    !(IPAddr.new(value) rescue nil).nil?
  end
end