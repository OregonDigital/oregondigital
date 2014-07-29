module BulkIngest
  class Delete
  @queue = :ingest
    def self.perform(task_id)
      task = BulkTask.find(task_id)
      task.delete_assets!
    end
  end
end
