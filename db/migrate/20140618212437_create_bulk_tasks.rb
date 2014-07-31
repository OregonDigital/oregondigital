class CreateBulkTasks < ActiveRecord::Migration
  def change
    create_table :bulk_tasks do |t|
      t.string  :status
      t.text    :directory
      t.text    :asset_ids
      t.text    :bulk_errors
    end
  end
end
