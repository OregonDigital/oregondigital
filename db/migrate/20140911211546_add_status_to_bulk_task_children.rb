class AddStatusToBulkTaskChildren < ActiveRecord::Migration
  def change
    add_column :bulk_task_children, :status, :string, :default => "pending"
  end
end
