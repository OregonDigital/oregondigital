class AddIngestedPidToBulkTaskChildren < ActiveRecord::Migration
  def change
    add_column :bulk_task_children, :ingested_pid, :string
  end
end
