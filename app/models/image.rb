class Image < GenericAsset
  has_file_datastream :name => 'thumbnail', :control_group => "E"
  has_file_datastream :name => 'medium', :control_group => "E"
  has_file_datastream :name => 'pyramidal', :control_group => "E"

  makes_derivatives do |obj|
    obj.create_thumbnail
    obj.workflowMetadata.has_thumbnail = true
    obj.create_medium
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

  def create_medium
    transform_datastream :content, {
        :thumb => {
            :datastream => 'medium',
            :size => '680x680>',
            :file_path => medium_image_location,
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

    def default_content_ds
      "medium"
    end

    def default_icon_base
      APP_CONFIG.try(:default_icon_path) || Rails.root.join("media", "default-thumbs")
    end

    def add_default_icon(icon, pid)
      path = thumbnail_location(pid)
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.cp(File.join(default_icon_base, icon), path)
    end
  end

  def pyramidal_tiff_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = APP_CONFIG.pyramidal_tiff_path || Rails.root.join("media", "pyramidal-tiffs")
    fd.extension = ".tiff"
    return fd.path
  end

  def medium_image_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = APP_CONFIG.try(:medium_image_path) || Rails.root.join("media", "medium-images")
    fd.extension = ".jpg"
    return fd.path
  end

  def thumbnail_location
    return ::Image.thumbnail_location(pid)
  end

end
