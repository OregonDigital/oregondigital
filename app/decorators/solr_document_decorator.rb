# View-specific logic for the solr documents that the CatalogController creates
class SolrDocumentDecorator < Draper::Decorator
  delegate_all

  # Figures out how this asset needs to be viewed when rendered by itself (i.e., probably won't
  # want to use this on the search index)
  def view_partial
    case self["active_fedora_model_ssi"]
      when "Image"
        # TODO: Fix this!  It's just temporary logic to test things out until we get dimensions
        # of the image into metadata
        if self["desc_metadata__title_ssm"].first =~ /iip/i
          return "large_image_viewer"
        else
          return "small_image_viewer"
        end

      when "Document"
        return "document_viewer"

      else
        return "generic_viewer"
    end
  end
end
