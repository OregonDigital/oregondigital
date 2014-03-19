module CollectionsHelper
  # Force Blacklight's facet stuff to load first so we can override its methods
  include Blacklight::FacetsHelperBehavior

  def controlled_view(pid)
    facet = @response.facets.find{|x| x.items.find{|y| y.value == pid}}
    return "" if !facet
    label_key = facet.name.split("_")
    label_key[label_key.length-1] = "label_#{label_key.last}"
    label_key = label_key.join("_")
    label_facet = @response.facets.find{|x| x.name == label_key}
    return "" if !label_facet
    new_pid_item = label_facet.items.find{|x| x.value.include?(pid)}
    return "" if !new_pid_item
    controlled_view_label(new_pid_item.value).first
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
