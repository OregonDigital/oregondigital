# View-specific logic for the solr documents that the CatalogController creates
class DocumentDecorator < GenericAssetDecorator

  def view_partial
    "document_viewer"
  end

  def view_div(&block)
    h.content_tag(:div, :id => "BookReader", :data => data_hash) do
      block.call if block_given?
    end
  end

  private

  def data_hash
    {
      :pages => pages,
      :title => title,
      :root => root
    }
  end

  def pages
    datastreams.keys.select{|x| x.start_with?("page")}.length
  end

  def title
    object.descMetadata.title.first
  end

  def root
    "/media/document_pages/#{pages_location.relative_path_from(base_pages_path)}"
  end

end
