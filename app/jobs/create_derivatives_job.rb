class CreateDerivativesJob
  @queue = :derivatives
  def self.perform(pid)
    object = ActiveFedora::Base.find(pid, :cast => true)
    object.create_derivatives if object.respond_to?(:create_derivatives)
  end
end
