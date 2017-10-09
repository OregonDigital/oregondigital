class OembedController < ApplicationController

  def traffic_control
    find_pid = /oregondigital:[0-9a-z]{9}/.match params[:url]
    return render_404 unless !find_pid.blank?
    pid = find_pid.to_s

    begin
      asset = GenericAsset.find(pid)

      return render_401 unless is_public(asset)
      
      if is_image(asset)
        return image_responder(pid, params[:format])
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
      return render_404 unless ((!asset.medium_image_location.blank?) && (File.exist? asset.medium_image_location))

      img = MiniMagick::Image.open(asset.medium_image_location)
      data = {
        "version" => "1.0",
        "type" => "photo",
        "width" => img['width'],
        "height" => img['height'], 
        "url" => "#{APP_CONFIG['default_url_host']}#{asset.medium_image_location.sub(Rails.root.to_s, '')}"
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


  def other_responder
    render_501
  end

  def other_response
    render_501
  end

  def json_response (data)
    response.headers['Content-Type'] = 'application/json'
    render body: JSON.generate(data)
  end

  def is_image (asset)
    asset.to_solr["has_model_ssim"].include? "Image"
  end

  def render_404
     render :text => "Not Found", :status => 404
  end

  def render_401
    render :text => "Not Authorized", :status => 401
  end

  def render_501
    render :text => "Not Implemented", :status => 501
  end

  def is_public(asset)
    asset.read_groups.include? "public"
  end

end

