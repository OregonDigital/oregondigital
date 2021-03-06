class Video < GenericAsset
  has_file_datastream :name => 'content_webm', :control_group => "E"
  has_file_datastream :name => 'content_mp4', :control_group => "E"

  makes_derivatives do |obj|
    obj.create_video_files
    obj.workflowMetadata.has_thumbnail = true
    obj.save
  end

  def webm_location
    fd = video_location
    fd.extension = ".webm"
    return fd.path
  end

  def mp4_location
    fd = video_location
    fd.extension = ".mp4"
    return fd.path
  end

  def thumbnail_location
    return ::Image.thumbnail_location(pid)
  end
  alias_method :jpg_location, :thumbnail_location
  
  def create_video_files
    transform_datastream :content, {
#        :webm => {
#          :format => "webm"
#        },
        :mp4 => {
          :format => "mp4"
        },
        :jpg => {
          :format => "jpg"
        }
    }, :processor => :video_filesystem
  end

  protected

  def video_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = video_base_path.join
    fd
  end

  def video_base_path
    return APP_CONFIG.try(:video_path) || Rails.root.join("media", "video")
  end
end
