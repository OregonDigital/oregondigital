# View-specific logic for the solr documents that the CatalogController creates
class ImageDecorator < GenericAssetDecorator

  def view_partial
    small_image_mime_types = ["image/jpeg"]
    if small_image_mime_types.include?(self.content.mimeType)
      return "small_image_viewer"
    end

    return "large_image_viewer"
  end

end
