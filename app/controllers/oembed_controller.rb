class OembedController < ApplicationController

  def traffic_control
    extract_pid(params[:url])
    return render_not_found unless !@pid.blank?
    @format = params[:format] || "json"
    return render_not_authorized unless is_public
    item_type = solr_doc["active_fedora_model_ssi"].downcase
    item_types.include?(item_type) ? send(item_type) : render_not_implemented
    rescue  OembedSolrError
      render_not_found
    rescue StandardError => e
      Rails.logger.error e.message
      render_server_error
  end

  def extract_pid(url)
    find_pid = /oregondigital:[0-9a-z]{9}/.match url
    @pid = find_pid.to_s 
  end

 def is_public
    solr_doc["read_access_group_ssim"].include? "public"
    rescue
      raise
  end

  #fwc will return an empty array if nothing found
  def solr_doc
    @solr_doc ||= ActiveFedora::Base.find_with_conditions({:id=>@pid}).first
    if @solr_doc.blank?
      raise OembedSolrError
    else
      @solr_doc
    end
  end

  def item_types
    ["image", "document"]
  end

## content methods
  def image
    location = "media/medium-images/#{loc}/#{modified_pid}.jpg"
    begin
      img = MiniMagick::Image.open(location)
      data = {
        "version" => "1.0",
        "type" => "photo",
        "width" => img['width'],
        "height" => img['height'], 
        "url" => "#{APP_CONFIG['default_url_host']}#{location}"
      }
      formatter(data)
    rescue
      raise
    end
  end

  def document
    width = solr_doc["leaf_metadata__pages__size__width_ssm"].first
    height = solr_doc["leaf_metadata__pages__size__height_ssm"].first
    html = "<iframe src=\"#{APP_CONFIG['default_url_host']}/embedded_reader/#{@pid}\" width=\"#{width}\" height=\"#{height}\"></iframe>"
    data = {
      "version" => "1.0",
      "type" => "rich",
      "html" => html,
      "width" => width,
      "height" => height
    }
    formatter(data)
    rescue
      raise
  end

  ##display helpers
  def formatter(data)
    if @format == 'json'
      json_response(data)
    else
      render_not_implemented
    end
    rescue
      raise
  end

  def json_response (data)
    response.headers['Content-Type'] = 'application/json'
    render body: JSON.generate(data)
    rescue
      raise
  end

  ##for displaying the bookreader
  def reader
    @pid = params[:id]
    @data_hash = data_hash
    render "oembed/reader", :layout => false
    rescue OembedSolrError
      render_not_found
    rescue StandardError => e
      Rails.logger.error e.message
      render_server_error
  end

  def data_hash
    {
    :pages => pages,
    :title => title,
    :root => root,
    :pid => @pid
    }
    rescue
      raise
  end

  def pages
    json['datastreams'].keys.select{|key, value| key.start_with?("page")}.size
    rescue
      raise
  end

  def title
    solr_doc["desc_metadata__title_ssm"].first
    rescue
      raise
  end

  def root
    "/media/document_pages/#{loc}/#{modified_pid}"
    rescue
      raise
  end

  def modified_pid
    @pid.gsub(":","-")
  end

  #match will return nil, but to_s on nil returns empty array
  def loc
    result = /thumbnails\/[a-z0-9]\/[a-z0-9]/.match path
    raise OembedSolrError unless !result.nil?
    result.to_s.gsub("thumbnails/","")
  end

  def path
    json["datastreams"]["thumbnail"]["dsLocation"]
    rescue
      raise
  end

  def json
    begin
      @json ||= JSON.parse(solr_doc["object_profile_ssm"].first)
    rescue JSON::ParserError
      raise
    end
  end

  ##error pages
  def render_not_authorized
    render :text => "Not Authorized", :status => 401
  end

  def render_not_found
     render :text => "Not Found", :status => 404
  end

  def render_server_error
    render :text => "Internal Server Error", :status => 500
  end

  def render_not_implemented
    render :text => "Not Implemented", :status => 501
  end

  class OembedSolrError < StandardError
  end

end

