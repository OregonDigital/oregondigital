class CreateIpRanges < ActiveRecord::Migration
  def change
    create_table :ip_ranges do |t|
      t.string :ip_start
      t.string :ip_end
      t.integer :ip_start_i
      t.integer :ip_end_i
      t.references :role

      t.timestamps
    end
    add_index :ip_ranges, :role_id
    add_index :ip_ranges, :ip_start_i
    add_index :ip_ranges, :ip_end_i
  end
end
