module BulkIngest
  class ReviewChild
  @queue = :ingest
    def self.perform(task_id)
      task = BulkTaskChild.find(task_id)
      task.review!
    end
  end
end
