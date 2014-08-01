class VideoDecorator < GenericAssetDecorator
  def view_partial
    "video_viewer"
  end

  def video_files
    webm_file.merge(mp4_file)
  end

  def webm_file
    {"video/webm" => "/media/video/"+Pathname.new(webm_location.to_s).relative_path_from(object.send(:video_base_path)).to_s}
  end

  def mp4_file
    {"video/mp4" => "/media/video/"+Pathname.new(mp4_location.to_s).relative_path_from(object.send(:video_base_path)).to_s}
  end
end
