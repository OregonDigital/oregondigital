module CollectionsHelper
  # Force Blacklight's facet stuff to load first so we can override its methods
  include Blacklight::FacetsHelperBehavior

  # TODO: We need to find a better way to do this - this means a solr call per facet. Fortunately, solr's fast.
  def controlled_view(pid)
    # Find documents which have info about this pid.
    documents = (Blacklight.solr.get "select", :qt => "search", :q => "desc_metadata__*:#{pid}")["response"]["docs"]
    # Get the relevant fields only.
    documents.map!{|x| x.select{|key, value| value.to_s.include?(pid)}}.reject!{|x| x.blank?}
    return "" if documents.blank?
    facet_name = documents.first.find{|key, value| Array.wrap(value).include?(pid)}.first
    return "" if !facet_name
    label_key = facet_name.split("_")
    label_key[label_key.length-1] = "label_#{label_key.last}"
    label_key = label_key.join("_")
    label_facet = documents.map{|x| x[label_key]}.flatten.compact
    return "" if label_facet.blank?
    controlled_view_label(label_facet).find{|x| !x.blank?}.to_s
  end

  def controlled_view_label(label)
    return controlled_view_label(label[:document][label[:field]]) if label.kind_of?(Hash)
    Array.wrap(label).map do |x|
      new_label = x.split("$")
      if new_label.first == new_label.last
        ""
      else
        new_label.first.strip
      end
    end
  end

  def should_render_facet? display_facet
    # Mutate display_facet so it doesn't include items which would render as blank.
    display_facet.items.select!{|x| !facet_display_value(display_facet.name, x).blank?}
    super(display_facet)
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
          :set => GenericCollection.id_param(item.split("$").last)
      }
    else
      super
    end
  end

end
