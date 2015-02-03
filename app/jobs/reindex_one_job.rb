class ReindexOneJob
  @queue = :reindex
  def self.perform(pid)
    ActiveFedora::Base.find(pid).update_index
  end
end
