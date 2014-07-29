module BulkIngest
  class Review
  @queue = :ingest
    def self.perform(task_id)
      task = BulkTask.find(task_id)
      task.review_assets!
    end
  end
end
