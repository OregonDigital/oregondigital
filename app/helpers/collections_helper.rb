module CollectionsHelper
  # Force Blacklight's facet stuff to load first so we can override its methods
  include Blacklight::FacetsHelperBehavior

  def collection_name(pid)
    document = @document_list.find{|x| x[Solrizer.solr_name("desc_metadata__set", :displayable)].to_a.include? pid}
    return "" if !document
    # NOTE - THIS MAKES A HUGE ASSUMPTION - labels must be indexed in the same order as the set it's with.
    index = document[Solrizer.solr_name("desc_metadata__set", :displayable)].index(pid)
    label = document[Solrizer.solr_name("desc_metadata__set_label", :displayable)].to_a[index]
  end

  def should_render_facet? display_facet
    display = facet_configuration_for_field(display_facet.name).show != false
    return display && display_facet.items.map{|x| facet_display_value(display_facet.name, x)}.select{|x| !x.blank?}.present?
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
