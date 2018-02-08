class Audio < GenericAsset
  has_file_datastream :name => 'content_ogg', :control_group => "E"
  has_file_datastream :name => 'content_mp3', :control_group => "E"

  makes_derivatives do |obj|
    obj.create_ogg
    obj.workflowMetadata.has_thumbnail = true
    ::Image.add_default_icon('audio.jpg', obj.pid)
    obj.save
  end

  def ogg_location
    fd = audio_location
    fd.extension = ".ogg"
    return fd.path
  end

  def mp3_location
    fd = audio_location
    fd.extension = ".mp3"
    return fd.path
  end

  def create_ogg
    transform_datastream :content, {
        :ogg => {
          :format => "ogg"
        },
        :mp3 => {
          :format => "mp3"
        }
    }, :processor => :audio_filesystem
  end

  protected

  def audio_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = audio_base_path.join
    fd
  end

  def audio_base_path
    return APP_CONFIG.try(:audio_path) || Rails.root.join("media", "audio")
  end

end
