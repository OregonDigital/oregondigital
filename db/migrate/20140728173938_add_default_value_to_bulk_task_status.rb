class AddDefaultValueToBulkTaskStatus < ActiveRecord::Migration
  def self.up
    change_column_default(:bulk_tasks, :status, "new")
  end

  def self.down
    change_column_default(:bulk_tasks, :status, nil)
  end
end
