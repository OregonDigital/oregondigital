class ReindexEverythingJob
  @queue = :reindex
  def self.perform
    ActiveFedora::Base.send(:connections).each do |conn|
      conn.search(nil) do |object|
        next if object.pid.start_with?('fedora-system:')
        Resque.enqueue(ReindexOneJob, object.pid)
      end
    end
  end
end
