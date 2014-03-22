class Image < GenericAsset
  has_file_datastream :name => 'thumbnail', :control_group => "E"
  has_file_datastream :name => 'pyramidal', :control_group => "E"

  makes_derivatives do |obj|
    obj.create_thumbnail
    obj.workflowMetadata.has_thumbnail = true
    obj.create_pyramidal
    obj.save
  end


  # Derivative Creation Methods

  def create_thumbnail
    transform_datastream :content, {
        :thumb => {
            :datastream => 'thumbnail',
            :size => '120x120>',
            :file_path => thumbnail_location,
            :format => 'jpeg',
            :quality => '75'
        }
    }, :processor => :image_filesystem_processor
  end

  def create_pyramidal
    transform_datastream :content, {
        :pyramidal => {
            :datastream => 'pyramidal',
            :file_path => pyramidal_tiff_location
        }
    }, :processor => :pyramidal_processor
  end

  # File locations

  class << self
    def thumbnail_base_path
      return APP_CONFIG.try(:thumbnail_path) || Rails.root.join("media", "thumbnails")
    end

    def thumbnail_location(pid)
      fd = OregonDigital::FileDistributor.new(pid)
      fd.base_path = thumbnail_base_path
      fd.extension = ".jpg"
      return fd.path
    end

    def relative_thumbnail_location(pid)
      return Pathname.new(thumbnail_location(pid).to_s).relative_path_from(thumbnail_base_path)
    end
  end

  def pyramidal_tiff_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = APP_CONFIG.pyramidal_tiff_path || Rails.root.join("media", "pyramidal-tiffs")
    fd.extension = ".tiff"
    return fd.path
  end

  def thumbnail_location
    return ::Image.thumbnail_location(pid)
  end

end
