class AudioDecorator < GenericAssetDecorator
  def view_partial
    "audio_viewer"
  end

  def audio_files
    ogg_file.merge(mp3_file)
  end

  def ogg_file
    {"application/ogg" => "/media/audio/"+Pathname.new(ogg_location.to_s).relative_path_from(object.send(:audio_base_path)).to_s}
  end

  def mp3_file
    {"audio/mpeg" => "/media/audio/"+Pathname.new(mp3_location.to_s).relative_path_from(object.send(:audio_base_path)).to_s}
  end
end
