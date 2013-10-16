# View-specific logic for the solr documents that the CatalogController creates
class DocumentDecorator < GenericAssetDecorator

  def view_partial
    "document_viewer"
  end

end
