class CreateIngestFileUploads < ActiveRecord::Migration
  def change
    create_table :ingest_file_uploads do |t|
      t.string :file
      t.timestamps
    end
  end
end
