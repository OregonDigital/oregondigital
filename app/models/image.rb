class Image < GenericAsset
  has_file_datastream :name => 'thumbnail', :control_group => "E"
  has_file_datastream :name => 'pyramidal', :control_group => "E"

  makes_derivatives :create_thumbnail, :create_pyramidal


  # Derivative Creation Methods

  def create_thumbnail
    transform_datastream :content, {
        :thumb => {
            :datastream => 'thumbnail',
            :size => '120x120>',
            :file_path => thumbnail_location,
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

  def pyramidal_tiff_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = APP_CONFIG.pyramidal_tiff_path || Rails.root.join("media", "pyramidal-tiffs")
    fd.extension = ".tiff"
    return fd.path
  end

  def thumbnail_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = APP_CONFIG.try(:thumbnail_path) || Rails.root.join("media", "thumbnails")
    fd.extension = ".png"
    return fd.path
  end

end
