module BulkIngest
  class IngestChild
  @queue = :ingest
    def self.perform(task_id)
      task = BulkTaskChild.find(task_id)
      task.ingest!
    end
  end
end
