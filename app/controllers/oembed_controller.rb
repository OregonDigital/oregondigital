class OembedController < ApplicationController

  def traffic_control
    find_pid = /oregondigital:[0-9a-z]{9}/.match params[:url]
    return render_404 unless !find_pid.blank?
    pid = find_pid.to_s

    begin
      asset = GenericAsset.find(pid)
      return render_404 unless !asset.nil?

      return render_501 unless is_public(asset)
      
      if is_image(asset)
        return image_responder(pid, params[:format])
      elsif is_video(asset)
        return video_responder(pid, params[:format])
      else
        return other_responder
      end

    rescue
      render_404
    end
  end

  def image_responder(pid, format)
    begin
      asset = Image.find(pid)
      return render_404 unless !asset.medium_image_location.blank?

      img = MiniMagick::Image.open(asset.medium_image_location)
      data = {
        "version" => "1.0",
        "type" => "photo",
        "width" => img['width'],
        "height" => img['height'], 
        "url" => "http://#{APP_CONFIG['default_url_host']}#{asset.medium_image_location.sub(Rails.root.to_s, '')}"
      }

      if format == 'json'
        json_response(data)
      else
        other_response
      end
    rescue
      return render_404
    end
  end

  def video_responder(pid, format)
    begin
      asset = Video.find(pid)
      return render_404 unless !asset.mp4_location.blank?

      url = "http://#{APP_CONFIG['default_url_host']}#{asset.mp4_location.sub(Rails.root.to_s, '')}"
      dim = get_dimensions(asset.mp4_location)
      data = {
        "version" => "1.0",
        "type" => "video",
        "width" => dim[:width],
        "height" => dim[:height],
        "html" => "<iframe width=\"#{dim[:width]}\" height=\"#{dim[:height]}\" src=\"#{url}\" frameborder=\"0\" allowfullscreen></iframe>"
      }

      if format == 'json'
        json_response(data)
      else
        other_response
      end
    rescue
      return render_404
    end
  end

  def get_dimensions(asset_path)
    begin
      command = "/home/lsato/Downloads/ffmpeg/ffprobe -v error -show_entries stream=width,height -of default=noprint_wrappers=1 \"#{asset_path}\""
      out, err, st = Open3.capture3(command)
      return nil unless st.success?
      widthmatch = /width=[0-9]*/.match out
      heightmatch = /height=[0-9]*/.match out
      return nil unless ( !widthmatch.blank? && !heightmatch.blank? )
      {:width => widthmatch.to_s.sub("width=",""), :height => heightmatch.to_s.sub("height=","")}
    rescue
      nil
    end
  end

  def other_responder
    render_401
  end

  def other_response
    render_401
  end

  def json_response (data)

    response.headers['Content-Type'] = 'application/json'
    render body: JSON.generate(data)
  end

  def is_image (asset)
    asset.to_solr["has_model_ssim"].include? "Image"
  end
  
  def is_video(asset)
    asset.to_solr["has_model_ssim"].include? "Video"
  end

  def render_404
    render :text => 'Not Found', :status => '404'
  end

  def render_401
    render :text => "Not Authorized", :status => '401'
  end

  def render_501
    render :text => 'Not Implemented', :status => '501'
  end

  def is_public(asset)
    asset.read_groups.include? "public"
  end

end

