class OembedController < ApplicationController

  def traffic_control
    find_pid = /oregondigital:[0-9a-z]{9}/.match params[:url]
    return render_404 unless !find_pid.blank?
    pid = find_pid.to_s

    begin
      return render_401 unless is_public
      
      if is_image
        return image_responder(params[:format])
      else
        return other_responder
      end

    rescue
      render_404
    end
  end

  def image_responder(format)
    location = "/media/medium-images/#{loc}/#{modified_pid}.jpg"
    begin
      img = MiniMagick::Image.open(location)
      data = {
        "version" => "1.0",
        "type" => "photo",
        "width" => img['width'],
        "height" => img['height'], 
        "url" => "#{APP_CONFIG['default_url_host']}#{location}"
      }
      if format == 'json'
        json_response(data)
      else
        other_response
      end
    rescue
      raise
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

  def is_image
    solr_doc["has_model_ssim"].include? "Image"
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

 def is_public
    solr_doc["read_access_group_ssim"].include? "public"
    rescue
      raise
  end

  #fwc will return an empty array if nothing found
  def solr_doc
    @solr_doc ||= ActiveFedora::Base.find_with_conditions({:id=>pid}).first
    if @solr_doc.blank?
      raise OembedSolrError
    else
      @solr_doc
    end
  end

  def json
    begin
      JSON.parse(solr_doc["object_profile_ssm"].first)
    rescue JSON::ParserError
      raise
    end
  end

  def path
    json["datastreams"]["thumbnail"]["dsLocation"]
    rescue
      raise
  end

  #match will return nil, but to_s on nil returns empty array
  def loc
    result = /thumbnails\/[a-z0-9]\/[a-z0-9]/.match path
    if result.nil?
      raise OembedSolrError
    end
    result.to_s.gsub("thumbnails/","")
  end

  class OembedSolrError < StandardError
  end

end

