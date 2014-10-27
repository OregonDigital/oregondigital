class AdjustIpRangeColumns < ActiveRecord::Migration
  def up
    change_column :ip_ranges, :ip_end_i, :integer, :limit => 5
    change_column :ip_ranges, :ip_start_i, :integer, :limit => 5
  end
  def down
    change_column :ip_ranges, :ip_end_i, :integer, :limit => 5
    change_column :ip_ranges, :ip_start_i, :integer, :limit => 5
  end
end
