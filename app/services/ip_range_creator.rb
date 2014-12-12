class IpRangeCreator
  def self.call(role, parameters, callbacks=[])
    new(role, parameters, callbacks).perform
  end

  attr_accessor :ip_range, :role, :callbacks, :parameters
  def initialize(role, parameters, callbacks)
    @role = role
    @parameters = parameters
    @callbacks = Array.wrap(callbacks)
  end

  def ip_range
    @ip_range ||= IpRange.new
  end

  def perform
    assign_parameters
    persist!
  end

  private

  def persist!
    return notify(:success) if ip_range.save
    notify(:failure)
  end

  def notify(status)
    callbacks.each do |callback|
      callback.send("create_#{status}", ip_range, role)
    end
  end

  def assign_parameters
    ip_range.ip_start = parameters[:ip_range_start]
    ip_range.ip_end = parameters[:ip_range_end]
    ip_range.role = role
  end
end
