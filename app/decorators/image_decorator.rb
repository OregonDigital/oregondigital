# View-specific logic for the solr documents that the CatalogController creates
class ImageDecorator < GenericAssetDecorator

  def view_partial
    if self.title =~ /iip/i
      "large_image_viewer"
    else
      "small_image_viewer"
    end
  end

end
