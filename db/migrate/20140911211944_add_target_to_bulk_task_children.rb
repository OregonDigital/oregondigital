class AddTargetToBulkTaskChildren < ActiveRecord::Migration
  def change
    add_column :bulk_task_children, :target, :string
  end
end
