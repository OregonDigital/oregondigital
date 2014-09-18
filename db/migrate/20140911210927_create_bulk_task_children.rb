class CreateBulkTaskChildren < ActiveRecord::Migration
  def change
    create_table :bulk_task_children do |t|
      t.references :bulk_task, index: true
      t.text :result

      t.timestamps
    end
  end
end
