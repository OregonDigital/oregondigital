# View-specific logic for the solr documents that the CatalogController creates
class ImageDecorator < GenericAssetDecorator

  def view_partial
    return "small_image_viewer" if small?

    return "large_image_viewer"
  end

  def small?
    small_image_mime_types.include?(self.object.content.mimeType)
  end

  def large?
    !small?
  end

  def tileSource
    return "" if small?
    "#{APP_CONFIG.iip_server.location}?DeepZoom=/#{relative_pyramidal_tiff_location}.dzi"
  end

  def relative_medium_image_location
    base_path = APP_CONFIG.try(:medium_image_path) || Rails.root.join("media", "medium-images")
    Pathname.new(medium_image_location.to_s).relative_path_from(base_path)
  end

  # TODO: Make this more manageable.
  def derivative_redirects
    { "medium" => "/media/medium-images/#{relative_medium_image_location}",
      "thumbnail" => "/thumbnails/#{Image.relative_thumbnail_location(pid)}"
    }
  end

  private

  def relative_pyramidal_tiff_location
    Pathname.new(pyramidal_tiff_location.to_s).relative_path_from(APP_CONFIG.pyramidal_tiff_path || Rails.root.join("media", "pyramidal-tiffs"))
  end

  def small_image_mime_types
    ["image/jpeg", "image/png"]
  end

end
