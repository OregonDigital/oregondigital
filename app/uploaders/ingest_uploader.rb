class IngestUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  storage :file
  process :set_content_type

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Use the central Rails tmp dir for upload caching
  def cache_dir
    "#{Rails.root}/tmp/upload-cache"
  end
end
