class ReindexEverythingJob
  @queue = :reindex
  def self.perform
    ActiveFedora::Base.send(:connections).each do |conn|
      conn.search(nil) do |object|
        next if object.pid.start_with?('fedora-system:')
        begin
        ActiveFedora::Base.find(object.pid).update_index
        rescue
        end
      end
    end
  end
end
