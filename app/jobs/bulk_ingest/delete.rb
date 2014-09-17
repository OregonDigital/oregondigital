module BulkIngest
  class Delete
  @queue = :ingest
    def self.perform(task_id)
      task = BulkTaskChild.find(task_id)
      task.delete_asset!
    end
  end
end
