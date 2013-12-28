module CollectionsHelper
  # Force Blacklight's facet stuff to load first so we can override its methods
  include Blacklight::FacetsHelperBehavior

  def collection_name(pid)
    GenericCollection.load_instance_from_solr(pid).decorate.title
  end

  def render_set(set)
    renderer = SetRenderer.new(set, lookup_context, params)
    render :template => renderer.partial_name
  end

  def add_facet_params_and_redirect(field, item)
    if field == ActiveFedora::SolrService.solr_name("desc_metadata__set", :facetable) && params[:search_field].blank? && params[:f].blank?
      {
          :controller => "sets",
          :action => "index",
          :set => GenericCollection.id_param(item)
      }
    else
      super
    end
  end

end
