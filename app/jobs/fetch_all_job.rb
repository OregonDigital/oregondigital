class FetchAllJob
  @queue = :fetch
  def self.perform(pid)
    object = ActiveFedora::Base.find(pid, :cast => true)
    object.descMetadata.fetch_external if object.descMetadata.respond_to?(:fetch_external)
  end
end
