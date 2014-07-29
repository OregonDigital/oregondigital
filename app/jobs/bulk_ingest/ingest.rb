module BulkIngest
  class Ingest
  @queue = :ingest
    def self.perform(task_id)
      task = BulkTask.find(task_id)
      task.ingest!
    end
  end
end
