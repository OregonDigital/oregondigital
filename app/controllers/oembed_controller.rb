class OembedController < ApplicationController

  def traffic_control
    return render_not_authorized unless is_public
    item_type = solr_doc["active_fedora_model_ssi"].downcase
    return render_not_implemented unless item_types.include?(item_type)
    formatter(send(item_type))
    rescue  OembedSolrError
      render_not_found
    rescue BadRequest
      render_bad_request
    rescue StandardError => e
      Rails.logger.error e.message
      render_server_error
  end

  def pid
    @pid ||= extract_pid
  end

  #if entry via #reader, params[:id] will be set
  #if entry via #traffic_control, params[:url] will be set
  def extract_pid
    find_pid = params[:id]
    find_pid ||= /oregondigital:[0-9a-z]{9}/.match params[:url]
    raise BadRequest if find_pid.nil?
    find_pid.to_s
  end

  def format
    @format ||= params[:format]
    raise BadRequest if @format.nil?
    @format
  end

  def is_public
    solr_doc["read_access_group_ssim"].include? "public"
  end

  def solr_doc
    @solr_doc ||= get_doc
  end

  #fwc will return an empty array if nothing found
  def get_doc
    doc = ActiveFedora::Base.find_with_conditions({:id=>pid}).first
    raise OembedSolrError if doc.blank?
    doc
  end

  def item_types
    ["image", "document"]
  end

## content methods
  def image
    location = "media/medium-images/#{buckets}/#{modified_pid}.jpg"
    img = MiniMagick::Image.open(location)
    data = {
      "version" => "1.0",
      "type" => "photo",
      "width" => img['width'],
      "height" => img['height'],
      "url" => URI.join(APP_CONFIG['default_url_host'], location).to_s
    }
  end

  def document
    width = "870"
    height = "600"
    url = URI.join(APP_CONFIG['default_url_host'], "embedded_reader/#{pid}").to_s
    html = "<iframe src=\"#{url}\" width=\"#{width}\" height=\"#{height}\"></iframe>"
    data = {
      "version" => "1.0",
      "type" => "rich",
      "html" => html,
      "width" => width,
      "height" => height
    }
  end

  #match will return nil, but to_s on nil returns empty array
  def buckets
    result = /thumbnails\/[a-z0-9]\/[a-z0-9]/.match path
    raise OembedSolrError if result.nil?
    result.to_s.gsub("thumbnails/","")
  end

  def path
    json["datastreams"]["thumbnail"]["dsLocation"]
  end

  def json
    @json ||= JSON.parse(solr_doc["object_profile_ssm"].first)
  end

  ##display helpers
  def formatter(data)
    if format == 'json'
      json_response(data)
    else
      render_not_implemented
    end
  end

  def json_response (data)
    response.headers['Content-Type'] = 'application/json'
    render body: JSON.generate(data)
  end

  ##for displaying the bookreader
  def reader
    @data_hash = data_hash
    render "oembed/reader", :layout => false
    rescue OembedSolrError
      render_not_found
    rescue StandardError => e
      Rails.logger.error e.message
      render_server_error
  end

  #using decorator view_div brings the surrounding layout
  def data_hash
    {
    :pages => pages,
    :title => title,
    :root => root,
    :pid => pid
    }
  end

  def pages
    json['datastreams'].keys.select{|key, value| key.start_with?("page")}.size
  end

  def title
    solr_doc["desc_metadata__title_ssm"].first
  end

  def root
    "/media/document_pages/#{buckets}/#{modified_pid}"
  end

  def modified_pid
    pid.gsub(":","-")
  end

  ##error pages
  def render_bad_request
    render :text => "Bad Request", :status => 400
  end

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

  ##custom errors
  class OembedSolrError < StandardError
  end

  class BadRequest < StandardError
  end
end

