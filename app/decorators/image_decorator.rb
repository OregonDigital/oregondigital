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

  private

  def relative_pyramidal_tiff_location
    Pathname.new(pyramidal_tiff_location.to_s).relative_path_from(APP_CONFIG.pyramidal_tiff_path || Rails.root.join("media", "pyramidal-tiffs"))
  end

  def small_image_mime_types
    ["image/jpeg"]
  end

end
